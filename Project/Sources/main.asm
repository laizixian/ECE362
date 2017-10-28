                    ; Generic assembly source file for testing code segments

        org     $800    ; location 800h is the beginning of SRAM
        ldaa    #$00
        ldab    #$10
        ldx     #$900
        ldd     #$10
        adda    [5,x]
        adda    1,-x
        adda    1,x+
        adda    b,x
        adda    5,x
        adda    68,x
        adda    512,x
        ldab    #$01
        adda    #$5  ; load first operand   
        adda    $900
        ;ldx     $900    
        ;adda    5,x
;        oraa    opand2  ; instruction(s) being tested (with second operand)
;        staa    result  ; store result
        stop		; (use location of STOP instruction for setting breakpoint)
        
        org     $905    ; place operand data at location 900h
        fcb     $1
        org     $8ff
        fcb     $12
        fcb     $2
        
        org     $920
        adda [d,x]
        

        
        
        end
        
;        org $800 ; BCD to Binary Conversion Program
;        ldaa bcdin ; (A) ? packed BCD input data
;        anda #$f0 ; mask off lower nibble
;         ; => (A) = 16 * (upper nibble)
;        lsra
;        tfr a,b ; (B) = 8 * (upper nibble)
;        lsra
;        lsra ; (A) = 2 * (upper nibble)
;        psha ; store temporarily on stack
;        addb 1,sp+ ; (B) = (2 + 8) * (upper nibble)
;        ldaa bcdin ; reload initial BCD data
;        anda #$0f ; mask off upper nibble
;        psha ; store temporarily on stack
;        addb 1,sp+ ; (B) = 10 * (un) + (ln)
;        stab binout ; store converted binary value
;        stop
;bcdin   fcb $34 ; BCD input data
;binout  rmb 1 ; location to store converted binary
;        end        
;        
;        org $800
;        ldaa #$50
;        ldab #$03
;        ldx 