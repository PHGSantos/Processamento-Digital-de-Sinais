#include <p33FJ256GP506.h>
#include "..\h\OCPWMDrv.h"
#include "..\h\sask.h"
#include "..\h\SFMDrv.h"
#include "..\h\G711.h"
#include "..\h\ADCChannelDrv.h"
#include <dsp.h>


_FGS(GWRP_OFF & GCP_OFF);
_FOSCSEL(FNOSC_FRC);
_FOSC(FCKSM_CSECMD & OSCIOFNC_ON & POSCMD_NONE);
_FWDT(FWDTEN_OFF);

/* FRAME_SIZE - Size of each audio frame
 * SPEECH_SEGMENT_SIZE - Size of intro speech segment
 * WRITE_START_ADDRESS - Serial Flash Memory write address
 * */

#define FRAME_SIZE 				128
#define SPEECH_SEGMENT_SIZE		98049L
#define WRITE_START_ADDRESS	0x20000
#define LOG2N 7
#define deslocamento 			25



/* Allocate memory for buffers and drivers	*/

int		adcBuffer		[ADC_CHANNEL_DMA_BUFSIZE] 	__attribute__((space(dma)));
int		ocPWMBuffer		[OCPWM_DMA_BUFSIZE]		__attribute__((space(dma)));
int		samples			[FRAME_SIZE];
char 	encodedSamples	[FRAME_SIZE];
int 	decodedSamples	[FRAME_SIZE];
char 	flashMemoryBuffer	[SFMDRV_BUFFER_SIZE];

fractcomplex fft_input[FRAME_SIZE] __attribute__((space(ymemory),   aligned(FRAME_SIZE*2*2))); 

fractcomplex twiddleFactorsFFT[FRAME_SIZE/2] 	/* Declare Twiddle Factor array in X-space*/
__attribute__ ((section (".xbss, bss, xmemory"), aligned (FRAME_SIZE*2)));

fractcomplex twiddleFactorsIFFT[FRAME_SIZE/2] 	/* Declare Twiddle Factor array in X-space*/
__attribute__ ((section (".xbss, bss, xmemory"), aligned (FRAME_SIZE*2)));

/* Instantiate the drivers 	*/
ADCChannelHandle adcChannelHandle;
OCPWMHandle 	ocPWMHandle;

/* Create the driver handles	*/
ADCChannelHandle *pADCChannelHandle 	= &adcChannelHandle;
OCPWMHandle 	*pOCPWMHandle 		= &ocPWMHandle;

/* Addresses
 * currentReadAddress - This one tracks the intro message
 * currentWriteAddress - This one tracks the writes to flash
 * userPlaybackAddress - This one tracks user playback
 * address - Used during flash erase
 * */

 long currentReadAddress;
 long currentWriteAddress;
 long userPlaybackAddress;
 long address;

 /* flags
 * record - if set means recording
 * playback - if set mean playback
 * erasedBeforeRecord - means SFM eras complete before record
 * */

int record;
int shift;
int playback;
int erasedBeforeRecord;

int main(void)
{
	/* Addresses
	 * currentReadAddress - This one tracks the intro message
	 * currentWriteAddress - This one tracks the writes to flash
	 * userPlaybackAddress - This one tracks user playback
	 * address - Used during flash erase
	 * */

	long currentReadAddress = 0;
	long currentWriteAddress = WRITE_START_ADDRESS;
	long userPlaybackAddress = WRITE_START_ADDRESS;
	long address = 0;

	/* flags
	 * record - if set means recording
	 * playback - if set mean playback
	 * erasedBeforeRecord - means SFM eras complete before record
	 * */

	int record = 0;
	int playback = 0;
	int erasedBeforeRecord = 0;
    int shift =0;

	/* Configure Oscillator to operate the device at 40MHz.
	 * Fosc= Fin*M/(N1*N2), Fcy=Fosc/2
	 * Fosc= 7.37M*40/(2*2)=80Mhz for 7.37M input clock */

	PLLFBD=41;				/* M=39	*/
	CLKDIVbits.PLLPOST=0;		/* N1=2	*/
	CLKDIVbits.PLLPRE=0;		/* N2=2	*/
	OSCTUN=0;

	__builtin_write_OSCCONH(0x01);		/*	Initiate Clock Switch to FRC with PLL*/
	__builtin_write_OSCCONL(0x01);
	while (OSCCONbits.COSC != 0b01);	/*	Wait for Clock switch to occur	*/
	while(!OSCCONbits.LOCK);


	/* Intialize the board and the drivers	*/
	SASKInit();
	ADCChannelInit	(pADCChannelHandle,adcBuffer);			/* For the ADC	*/
	OCPWMInit		(pOCPWMHandle,ocPWMBuffer);			/* For the OCPWM	*/

	/* Open the flash and unprotect it so that
	 * it can be written to.
	 * */

	SFMInit(flashMemoryBuffer);


	/* Start Audio input and output function	*/
	ADCChannelStart	(pADCChannelHandle);
	OCPWMStart		(pOCPWMHandle);

    // Declações FFT
    TwidFactorInit (LOG2N, &twiddleFactorsFFT[0], 0);
	TwidFactorInit (LOG2N, &twiddleFactorsIFFT[0], 1); 
    
	/* Main processing loop. Executed for every input and
	 * output frame	*/
    
    int i=0;
    int j=0;

	while(1)
	{
        
        /* Obtaing the ADC samples	*/
		while(ADCChannelIsBusy(pADCChannelHandle));
		ADCChannelRead	(pADCChannelHandle,samples,FRAME_SIZE);
            
            
        if(record == 1)
			{

				if(erasedBeforeRecord == 0)
				{
					/* Stop the Audio input and output since this is a blocking
					 * operation. Also rewind record and playback pointers to
					 * start of the user flash area. Erase the user side of
					 * SFM memory blocks. Also set the erasedBeforeRecord flag
					 * so that this is done only once before record. Start the
					 * ADC and OCPWM when the erase is complete.
					 * */

					ADCChannelStop(pADCChannelHandle);
					OCPWMStop	(pOCPWMHandle);
					currentWriteAddress = WRITE_START_ADDRESS;
					userPlaybackAddress = WRITE_START_ADDRESS;
					RED_LED = SASK_LED_ON;
					YELLOW_LED = SASK_LED_OFF;

          // faz a limpesa
					for(address = WRITE_START_ADDRESS;
							address < SFM_LAST_ADDRESS;
						   	address += 0x10000)
					{
						SFMBlockErase(address);

					}
					RED_LED = SASK_LED_OFF;

					erasedBeforeRecord = 1;
					ADCChannelStart(pADCChannelHandle);
					OCPWMStart		(pOCPWMHandle);
				}
				else
				{
					/* Record the encoded audio frame. Yellow LED turns on when
					 * when recording is being performed. Store the encoded
					 * buffer into SFM. If the last SFM address is reached then
					 * stop recording and start playback.
					 * */

					YELLOW_LED = SASK_LED_ON;
					G711Lin2Ulaw(samples,encodedSamples,FRAME_SIZE);

					currentWriteAddress += SFMWrite(currentWriteAddress,
								encodedSamples,FRAME_SIZE);

					if(currentWriteAddress >= SFM_LAST_ADDRESS)
					{
						YELLOW_LED = SASK_LED_OFF;
						erasedBeforeRecord = 0;
						record = 0;
						playback = 1;
					}
				}

			}

        /* If playback is enabled, then start playing back samples from the
         * user area. Playback only till the last record address and then
         * rewind to the start	*/

        if(playback == 1)
        {
            GREEN_LED = SASK_LED_ON;
            erasedBeforeRecord = 0;
            userPlaybackAddress += SFMRead(userPlaybackAddress,
                            encodedSamples,FRAME_SIZE);
            if(userPlaybackAddress >= currentWriteAddress)
            {
                userPlaybackAddress = WRITE_START_ADDRESS;
                shift = 1;
            }
        }
        
        /* Decode the samples	*/
		G711Ulaw2Lin (encodedSamples,decodedSamples, FRAME_SIZE);
        
        if (shift = 1){
            for(i=0; i<FRAME_SIZE; i++)
            {
                fft_input[i].real = decodedSamples[i];
                fft_input[i].real = fft_input[i].real>>1;
                fft_input[i].imag = 0x0000;            
            }
            
            /* Perform FFT operation */

            FFTComplexIP (LOG2N, &fft_input[0], &twiddleFactorsFFT[0], COEFFS_IN_DATA);
            
                /* Store output samples in bit-reversed order of their addresses */
            BitReverseComplex (LOG2N, &fft_input[0]);

            for (i=FRAME_SIZE; i>deslocamento; i--){
                fft_input[i] =  fft_input[i-deslocamento];

            }

             for (i=0; i<deslocamento; i++){
                fft_input[i].imag = Q15(0);
                 fft_input[i].real = Q15(0);

            }

            IFFTComplexIP (LOG2N, &fft_input[0], &twiddleFactorsIFFT[0], COEFFS_IN_DATA);

            for(i=0; i<128; i++)
            {
                decodedSamples[i] = (fft_input[i].real<<10);         //  
            }
            
        }
        

			/* Wait till the OC is available for a new  frame	*/
			while(OCPWMIsBusy(pOCPWMHandle));

			/* Write the frame to the output	*/
			OCPWMWrite (pOCPWMHandle,decodedSamples,FRAME_SIZE);

			/* The CheckSwitch functions are defined in sask.c	*/
        
        	if((CheckSwitchS1()) == 1)
			{
				/* Toggle the record function and Yellow led.
				 * Rewind the intro message playback pointer.
				 * And if recording, disable playback.*/


				record = 1;
                shift =0;
				currentReadAddress = 0;
				erasedBeforeRecord = 0;
				if(record == 1)
				{
					playback = 0;
					GREEN_LED = SASK_LED_OFF;
				}
				else
				{
					YELLOW_LED = SASK_LED_OFF;
				}
			}


			if((CheckSwitchS2()) == 1)
			{
				/* Toggle the record function and AMBER led.
				 * Rewind the intro message playback pointer.
				 * And if recording, disable playback.*/

				GREEN_LED =1; //apaga
				playback =1;
				currentReadAddress = 0;
				userPlaybackAddress = WRITE_START_ADDRESS;
				if(playback == 1)
				{
					record = 0;
					YELLOW_LED = SASK_LED_OFF;
				}
			}

        
	
	}//Fim While


}