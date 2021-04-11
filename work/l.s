* ANIMATED RUNNING WOLF
* HGR image ("LOUP") must be loaded @ $6000 first
* This program split the "LOUP" image in 9 pieces
* and sends these 9 parts to HGR screen
* thus creating an animation
*
*
* ROM routines
        lst off
*
home    equ $FC58
text    equ $FB2F
col80off equ $C00C
cout    equ $FDED
vtab    equ $FC22
getln   equ $FD6A
bascalc equ $FBC1
cr      equ $FD8E      ; print carriage return 
clreop  equ $FC42      ; clear from cursor to end of page
clreol  equ $FC9C      ; clear from cursor to end of line
xtohex  equ $F944
rdkey   equ $FD0C      ; wait for keypress
auxmov  equ $C311      
xfer    equ $C314
wait    equ $FCA8
*
* ROM switches
*
graphics equ $C050
mixoff   equ $C052
hires    equ $C057
page1    equ $C054
page2    equ $C055
clr80col equ $C000 
vbl      equ $C019   
kbd      equ $C000
kbdstrb  equ $C010  
*
ptr     equ $06
ptr2    equ $08
* 
* CONST
posx    equ $0C
posy    equ $40
delay   equ $A0
*
        org $8000
        lda #17         ; 40 col. 
        jsr cout
        jsr clear1      ; clear HGR
        bit kbdstrb     ; Clear out any data that is already at KBD
*
        lda page1
        lda mixoff      ; no text
        lda graphics    ; graphic mode
        lda hires       ; hgr 
        jsr docolor     ; change color (high) bit of images
*
mainlp  nop
        bit kbd
        bmi dokey
        lda switch      ; toggle page1 / page2
        eor #$01
        sta switch
        bne p1 
        jsr dovbl       ; wait for VBL
        lda page2       ; display page 2, switch = 0
        jmp main2 
p1      jsr dovbl
        lda page1       ; display page 1, switch = 1
main2   jsr setvars     ; prepare vars 
        bcs exit        ; end of frames ? yes : end
        jsr doframe     ; draw a frame, in p1 or p2
* double buffering
* if page 1 is on (switch = 1), we draw on page 2
* if page 2 is on (switch = 0), we draw on page 1
*
        lda #delay      ; delay between frames
        jsr wait
        inc framenb     ; next frame
        jmp mainlp      ; loop
*
dokey   lda kbd
        cmp #$A0        ; space char ?
        bne exit
        bit kbdstrb     ; Clear out any data that is already at KBD
waitk   bit kbd
        bpl waitk
        bit kbdstrb
        jmp mainlp
*
exit    bit kbdstrb
        jsr home
        jsr text
        rts
*
* UPDATE all vars
* to prepare a frame display
* according to frame number and animm array.
*
setvars lda framenb     ; frame counter
        asl
        asl             ; x 4 (4 bytes per frame)
        sta curpos      ; position in anim array
        tax
        lda anim,x
        cmp #$FF        ; $FF = flag for end of array
        bne notfinished
        lda #$00        ; for infinite loop
        sta framenb     ; for infinite loop
        jmp setvars     ; for infinite loop
        sec             ; flag : C=1 : no more frame to draw
        rts             ; we should never get here
notfinished sta xstart  ; updates x pos of upperleft corner
        inx 
        lda anim,x
        sta xend        ; updates x pos of downright corner
        inx
        lda anim,x
        sta ystart      ; updates y pos of upperleft corner
        inx
        lda anim,x      ; updates y pos of downright corner
        sta yend
        lda #posx       ; reset destination position in HGR1
        sta dxstart     ; of upperleft corner
        lda #posy
        sta dystart
        clc             ; flag : C=0 : not finished
        rts
*
*
doframe ldx dystart      ; get dest y pos (line #)    
        lda hi,x         ; set destination line pointer (ptr), $2000
        ldy switch
        beq do2000
        clc 
        adc #$20        ; ofr page 2 ($4000)
do2000  sta ptr+1
        lda lo,x 
        sta ptr
*
        ldx ystart      ; get source y pos. (line #) 
        lda hi,x        ; set source line pointer
        clc
        adc #$40        ; $2000... ==> $6000...
        sta ptr2+1      ; set source line pointer (ptr2), $6000
        lda lo,x 
        sta ptr2
*
        lda xstart      ; save x pos. pointers (source and dest.)
        sta tempy1
        lda dxstart
        sta tempy2
loopln  ldy xstart      ; get source x pos.
        lda (ptr2),y    ; get source byte
        ldy dxstart     ; get destination x pos.
        sta (ptr),y     ; poke destination byte
        inc xstart      ; next byte in source row
        inc dxstart     ; next byte in destination row
        lda xstart
        cmp xend        ; end of line ?
        bne loopln      ; no : loop
        inc dystart     ; next line (destination)
        inc ystart      ; next line (source)
        lda tempy1      ; restore x pos. pointers
        sta xstart      ; for the next line
        lda tempy2
        sta dxstart
        lda ystart
        cmp yend        ; last line ?
        bne doframe     ; no : loop
        rts
*
*
* clear HGR screen ($2000 + $4000) with color1
*
clear1  ldx #$00
c2      lda lo,x
        sta ptr
        lda hi,x
        sta ptr+1
        ldy #$27
        lda color1
c1      sta (ptr),y
        dey
        bpl c1
        inx
        cpx #$C0       ; 192 ligne
        bne c2
*
cls4000 ldx #$00
c24     lda lo,x
        sta ptr
        lda hi,x
        clc
        adc #$20
        sta ptr+1
        ldy #$27
        lda color1
c14     sta (ptr),y
        dey
        bpl c14
        inx
        cpx #$C0        ; 192 ligne
        bne c24
        lda #$FF        ; to see page1/page2 alternate
        sta $4000
        rts
*
* change high bit of source images ($6000 to $7FFF)
docolor lda #$60            ; set pointer
        sta ptr+1
        lda #$00
        sta ptr
        ldy #$00
lcolor  lda (ptr),y         ; get image byte
        and #$7F            ; set high bit to 0
        sta (ptr),y         ; poke byte
        iny
        bne lcolor          ; loop in page
        inc docolor+1       ; self modifying code
        lda docolor+1       ; to get next page
        cmp #$80            ; end reached ?
        bne docolor
        lda #$60            ; reset code
        sta docolor+1
        rts
*
* wait for VBL
dovbl   nop
        pha
loopvbl lda vbl
        bmi loopvbl
        pla 
        rts
*
switch  hex 00
color1  hex 00

tempy1  hex 00      ; tempo var
tempy2  hex 00

curpos  hex 00      ; unused
framenb hex 00      ; frem counter

xstart  hex 00      ; x pos. of source
xend    hex 00
ystart  hex 00      ; y pos. of source
yend    hex 00

dxstart hex 00      ; dstination position (x,y)
dystart hex 00

* anim : array of 4 bytes per frame
* each frame has :
* xstart, xend, ystart, yend
* FF is a flag at the end.
anim    hex 000D00400D1A0040    ; 2 frames
        hex 1A280040            ; +1 frame : 3 frames on same row
        hex 000D40800D1A4080    ; 2 frames
        hex 1A284080            ; +1 frame : 3 frames on same row
        hex 000D80C00D1A80C0    ; 2 frames
        hex 1A2880C0            ; +1 frame : 3 frames on same row
        hex FF                  ; marker for end.
*
hi      hex 2024282C3034383C    ; high byte of HGR memory address
        hex 2024282C3034383C
        hex 2125292D3135393D
        hex 2125292D3135393D
        hex 22262A2E32363A3E
        hex 22262A2E32363A3E
        hex 23272B2F33373B3F
        hex 23272B2F33373B3F
        hex 2024282C3034383C
        hex 2024282C3034383C
        hex 2125292D3135393D
        hex 2125292D3135393D
        hex 22262A2E32363A3E
        hex 22262A2E32363A3E
        hex 23272B2F33373B3F
        hex 23272B2F33373B3F
        hex 2024282C3034383C
        hex 2024282C3034383C
        hex 2125292D3135393D
        hex 2125292D3135393D
        hex 22262A2E32363A3E
        hex 22262A2E32363A3E
        hex 23272B2F33373B3F
        hex 23272B2F33373B3F
lo      hex 0000000000000000        ; low byte of HGR memory address
        hex 8080808080808080
        hex 0000000000000000
        hex 8080808080808080
        hex 0000000000000000
        hex 8080808080808080
        hex 0000000000000000
        hex 8080808080808080
        hex 2828282828282828
        hex A8A8A8A8A8A8A8A8
        hex 2828282828282828
        hex A8A8A8A8A8A8A8A8
        hex 2828282828282828
        hex A8A8A8A8A8A8A8A8
        hex 2828282828282828
        hex A8A8A8A8A8A8A8A8
        hex 5050505050505050
        hex D0D0D0D0D0D0D0D0
        hex 5050505050505050
        hex D0D0D0D0D0D0D0D0
        hex 5050505050505050
        hex D0D0D0D0D0D0D0D0
        hex 5050505050505050
        hex D0D0D0D0D0D0D0D0
*