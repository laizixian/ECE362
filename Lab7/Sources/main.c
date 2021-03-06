// ***********************************************************************
//  ECE 362 - Experiment 7 - Fall 2016
//
// Dual-channel LED bar graph display                    
// ***********************************************************************
//	 	   			 		  			 		  		
// Completed by: < Zixian Lai >
//               < 9418-L >
//               < 001 >
//               < 10/25/2016 >
//
//
// Academic Honesty Statement:  In entering my name above, I hereby certify
// that I am the individual who created this HC(S)12 source file and that I 
// have not copied the work of any other student (past or present) while 
// completing it. I understand that if I fail to honor this agreement, I will 
// receive a grade of ZERO and be subject to possible disciplinary action.
//
// ***********************************************************************

#include <hidef.h>           /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <mc9s12c32.h>

// All funtions after main should be initialized here

// Note: inchar and outchar can be used for debugging purposes

char inchar(void);
void outchar(char x);
			 		  		
//  Variable declarations  	   			 		  			 		       
int tenthsec = 0;  // one-tenth second flag
int leftpb = 0;    // left pushbutton flag
int rghtpb = 0;    // right pushbutton flag
int runstp = 0;    // run/stop flag                         
int rticnt = 0;    // RTICNT (variable)
int prevpbl = 0;    // previous state of pushbuttons (variable)
int prevpbr = 0;
int out_put0 = 0;
int out_put1 = 0;

	 	   		
// Initializations
 
void  initializations(void) {

// Set the PLL speed (bus clock = 24 MHz)

  		CLKSEL = CLKSEL & 0x80; // disengage PLL from system
  		PLLCTL = PLLCTL | 0x40; // turn on PLL
  		SYNR = 0x02;            // set PLL multiplier
  		REFDV = 0;              // set PLL divider
  		while (!(CRGFLG & 0x08)){  }
  		CLKSEL = CLKSEL | 0x80; // engage PLL
  
// Disable watchdog timer (COPCTL register)

      COPCTL = 0x40;    //COP off - RTI and COP stopped in BDM-mode

// Initialize asynchronous serial port (SCI) for 9600 baud, no interrupts

      SCIBDH =  0x00; //set baud rate to 9600
      SCIBDL =  0x9C; //24,000,000 / 16 / 156 = 9600 (approx)  
      SCICR1 =  0x00; //$9C = 156
      SCICR2 =  0x0C; //initialize SCI for program-driven operation
         
//  Initialize Port AD pins 7 and 6 for use as digital inputs

	    DDRAD = 0; 		//program port AD for input mode
      ATDDIEN = 0xC0; //program PAD7 and PAD6 pins as digital inputs
         
//  Add additional port pin initializations here  (e.g., Other DDRs, Ports) 
			DDRT = 0xff;
			PTT_PTT0 = 0;
			PTT_PTT1 = 0;

//  Define bar graph segment thresholds (THRESH1..THRESH5)
//  NOTE: These are binary fractions
#define THRESH1 0x2A  
#define THRESH2 0x55
#define THRESH3 0x80
#define THRESH4 0xAA
#define THRESH5 0xD5 


//  Add RTI/interrupt initializations here
      CRGINT = 0b10000000;
      RTICTL = 0b01110000;
      ATDCTL2 = 0b11000000; 
      ATDCTL3 = 0b00010000;
      ATDCTL4 = 0b10000101;
}
	 		  			 		  		
 
// Main (non-terminating loop)
 
void main(void) {
	initializations(); 		  			 		  		
	EnableInterrupts;


  for(;;)
  {
    if(tenthsec == 1)
    {
      tenthsec = 0;
    
      if(runstp == 1)
      {
        ATDCTL5 = 0b00010000;
        //channel 1
        if(ATDDR0 >= THRESH5 || (ATDDR0 >= THRESH4 && ATDDR0 < THRESH5)
        {
          out_put0 = 5;
        }
        if(ATDDR0 >= THRESH3 && ATDDR0 < THRESH4)
        {
          out_put0 = 4;
        }
        if(ATDDR0 >= THRESH2 && ATDDR0 < THRESH3)
        {
          out_put0 = 3;
        }
        if(ATDDR0 >= THRESH1 && ATDDR0 < THRESH2)
        {
          out_put0 = 2;
        }
        if(ATDDR0 < THRESH1)
        {
          out_put0 = 1;
        }
        //channel 1
        if(ATDDR1 >= THRESH5 || (ATDDR1 >= THRESH4 && ATDDR1 < THRESH5)
        {
          out_put0 = 5;
        }
        if(ATDDR1 >= THRESH3 && ATDDR1 < THRESH4)
        {
          out_put0 = 4;
        }
        if(ATDDR1 >= THRESH2 && ATDDR1 < THRESH3)
        {
          out_put0 = 3;
        }
        if(ATDDR1 >= THRESH1 && ATDDR1 < THRESH2)
        {
          out_put0 = 2;
        }
        if(ATDDR1 < THRESH1)
        {
          out_put0 = 1;
        }
      
        for(int i =0; i < 10; i++)
        {
          PTT_PTT4 = 0;
          if(i < 5) 
          {
            if(out_put0 > 0)
            {
              PTT_PTT3 = 1;
              out_put0--;
            }
            else
            {
              PTT_PTT3 = 0;
            }
          }
          else
          {
            if(out_put1 > 0)
            {
              PTT_PTT3 = 1;
              out_put1--;
            }
            else
            {
              PTT_PTT3 = 0;
            }
          }
          PTT_PTT4 = 1;
        }
      }   
    }
    
    if(leftpb == 1)
    {
      PTT_PTT0 = 0;   
      PTT_PTT1 = 1;
      leftpb = 0;
      runstp = 0; 
    }
  
    if(rghtpb == 1)
    {
      PTT_PTT0 = 1;    
      PTT_PTT1 = 0;
      rghtpb = 0;
      runstp = 1;
    }


// Main program loop (state machine)
// Start of main program-driven polling loop

	 	   			 		  			 		  		
//  If the "tenth second" flag is set, then
//    - clear the "tenth second" flag
//    - if "run/stop" flag is set, then
//       - initiate ATD coversion sequence
//       - apply thresholds to converted values
//       - determine 5-bit bar graph bit settings for each input channel
//       - transmit 10-bit data to external shift register
//    - endif
//  Endif

	 	   			 		  			 		  		
//  If the left pushbutton ("stop BGD") flag is set, then:
//    - clear the left pushbutton flag
//    - clear the "run/stop" flag (and "freeze" BGD)
//    - turn on left LED/turn off right LED (on docking module)
//  Endif
   			 		  			 		  		

//  If the right pushbutton ("start BGD") flag is set, then
//    - clear the right pushbutton flag
//    - set the "run/stop" flag (enable BGD updates)
//    - turn off left LED/turn on right LED (on docking module)
//  Endif
	 	   			 		  			 		  		

  } /* loop forever */
  
}  /* make sure that you never leave main */



// ***********************************************************************                       
// RTI interrupt service routine: rti_isr
//
//  Initialized for 5-10 ms (approx.) interrupt rate - note: you need to
//    add code above to do this
//
//  Samples state of pushbuttons (PAD7 = left, PAD6 = right)
//
//  If change in state from "high" to "low" detected, set pushbutton flag
//     leftpb (for PAD7 H -> L), rghtpb (for PAD6 H -> L)
//     Recall that pushbuttons are momentary contact closures to ground
//
//  Also, keeps track of when one-tenth of a second's worth of RTI interrupts
//     accumulate, and sets the "tenth second" flag         	   			 		  			 		  		
 
interrupt 7 void RTI_ISR( void)
{
 // set CRGFLG bit to clear RTI device flag
  	CRGFLG = CRGFLG | 0x80;
  	 
	  if((PORTAD0_PTAD7 + prevpbl) == 0){       // if left button is pressed and detected high to low edge
  		prevpbl = 1;                            // set previous push button left 
  		leftpb = 1;                             // set push button left 
  	}
  	else if (PORTAD0_PTAD7 == 1){             // if left putton is not pressed
  		prevpbl = 0;                            // clear previous push button left
  	}
  	
  	if((PORTAD0_PTAD6 + prevpbr) == 0){
  	  prevpbr = 1;
  	  rghtpb = 1;
  	} 
  	else if (PORTAD0_PTAD6 == 1){
  	  prevpbr = 0;
  	}
  	  
  	if (rticnt == 10) {
  	  tenthsec = 1;
  	  rticnt = 0;
  	}
  	else{
  	  rticnt++;  
  	}

}


// ***********************************************************************
// Character I/O Library Routines for 9S12C32 (for debugging only)
// ***********************************************************************
// Name:         inchar
// Description:  inputs ASCII character from SCI serial port and returns it
// ***********************************************************************
char  inchar(void) {
  /* receives character from the terminal channel */
        while (!(SCISR1 & 0x20)); /* wait for RDR input */
    return SCIDRL;
 
}

// ***********************************************************************
// Name:         outchar
// Description:  outputs ASCII character passed in outchar()
//                  to the SCI serial port
// ***********************************************************************/
void outchar(char ch) {
  /* transmits a character to the terminal channel */
    while (!(SCISR1 & 0x80));  /* wait for TDR empty */
    SCIDRL = ch;
}

