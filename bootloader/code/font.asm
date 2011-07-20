; 8x8 ascii font (32-127)
; taken from TONC : http://www.coranac.com/tonc/text/text.htm
font_data:
db $00,$00,$00,$00,$00,$00,$00,$00 ;  
db $18,$18,$18,$18,$18,$00,$18,$00 ; !
db $6c,$6c,$00,$00,$00,$00,$00,$00 ; "
db $6c,$6c,$fe,$6c,$fe,$6c,$6c,$00 ; #
db $18,$3e,$60,$3c,$06,$7c,$18,$00 ; $
db $00,$66,$ac,$d8,$36,$6a,$cc,$00 ; %
db $38,$6c,$68,$76,$dc,$ce,$7b,$00 ; &
db $18,$18,$30,$00,$00,$00,$00,$00 ; '
db $0c,$18,$30,$30,$30,$18,$0c,$00 ; (
db $30,$18,$0c,$0c,$0c,$18,$30,$00 ; )
db $00,$66,$3c,$ff,$3c,$66,$00,$00 ; *
db $00,$18,$18,$7e,$18,$18,$00,$00 ; +
db $00,$00,$00,$00,$00,$18,$18,$30 ; ,
db $00,$00,$00,$7e,$00,$00,$00,$00 ; -
db $00,$00,$00,$00,$00,$18,$18,$00 ; .
db $03,$06,$0c,$18,$30,$60,$c0,$00 ; /
db $3c,$66,$6e,$7e,$76,$66,$3c,$00 ; 0
db $18,$38,$78,$18,$18,$18,$18,$00 ; 1
db $3c,$66,$06,$0c,$18,$30,$7e,$00 ; 2
db $3c,$66,$06,$1c,$06,$66,$3c,$00 ; 3
db $1c,$3c,$6c,$cc,$fe,$0c,$0c,$00 ; 4
db $7e,$60,$7c,$06,$06,$66,$3c,$00 ; 5
db $1c,$30,$60,$7c,$66,$66,$3c,$00 ; 6
db $7e,$06,$06,$0c,$18,$18,$18,$00 ; 7
db $3c,$66,$66,$3c,$66,$66,$3c,$00 ; 8
db $3c,$66,$66,$3e,$06,$0c,$38,$00 ; 9
db $00,$18,$18,$00,$00,$18,$18,$00 ; :
db $00,$18,$18,$00,$00,$18,$18,$30 ; ;
db $00,$06,$18,$60,$18,$06,$00,$00 ; <
db $00,$00,$7e,$00,$7e,$00,$00,$00 ; =
db $00,$60,$18,$06,$18,$60,$00,$00 ; >
db $3c,$66,$06,$0c,$18,$00,$18,$00 ; ?
db $3c,$66,$5a,$5a,$5e,$60,$3c,$00 ; @
db $3c,$66,$66,$7e,$66,$66,$66,$00 ; A
db $7c,$66,$66,$7c,$66,$66,$7c,$00 ; B
db $1e,$30,$60,$60,$60,$30,$1e,$00 ; C
db $78,$6c,$66,$66,$66,$6c,$78,$00 ; D
db $7e,$60,$60,$78,$60,$60,$7e,$00 ; E
db $7e,$60,$60,$78,$60,$60,$60,$00 ; F
db $3c,$66,$60,$6e,$66,$66,$3e,$00 ; G
db $66,$66,$66,$7e,$66,$66,$66,$00 ; H
db $3c,$18,$18,$18,$18,$18,$3c,$00 ; I
db $06,$06,$06,$06,$06,$66,$3c,$00 ; J
db $c6,$cc,$d8,$f0,$d8,$cc,$c6,$00 ; K
db $60,$60,$60,$60,$60,$60,$7e,$00 ; L
db $c6,$ee,$fe,$d6,$c6,$c6,$c6,$00 ; M
db $c6,$e6,$f6,$de,$ce,$c6,$c6,$00 ; N
db $3c,$66,$66,$66,$66,$66,$3c,$00 ; O
db $7c,$66,$66,$7c,$60,$60,$60,$00 ; P
db $78,$cc,$cc,$cc,$cc,$dc,$7e,$00 ; Q
db $7c,$66,$66,$7c,$6c,$66,$66,$00 ; R
db $3c,$66,$70,$3c,$0e,$66,$3c,$00 ; S
db $7e,$18,$18,$18,$18,$18,$18,$00 ; T
db $66,$66,$66,$66,$66,$66,$3c,$00 ; U
db $66,$66,$66,$66,$3c,$3c,$18,$00 ; V
db $c6,$c6,$c6,$d6,$fe,$ee,$c6,$00 ; W
db $c3,$66,$3c,$18,$3c,$66,$c3,$00 ; X
db $c3,$66,$3c,$18,$18,$18,$18,$00 ; Y
db $fe,$0c,$18,$30,$60,$c0,$fe,$00 ; Z
db $3c,$30,$30,$30,$30,$30,$3c,$00 ; [
db $c0,$60,$30,$18,$0c,$06,$03,$00 ; \
db $3c,$0c,$0c,$0c,$0c,$0c,$3c,$00 ; ]
db $18,$3c,$66,$00,$00,$00,$00,$00 ; ^
db $00,$00,$00,$00,$00,$00,$fc,$00 ; _
db $18,$18,$0c,$00,$00,$00,$00,$00 ; `
db $00,$00,$3c,$06,$3e,$66,$3e,$00 ; a
db $60,$60,$7c,$66,$66,$66,$7c,$00 ; b
db $00,$00,$3c,$60,$60,$60,$3c,$00 ; c
db $06,$06,$3e,$66,$66,$66,$3e,$00 ; d
db $00,$00,$3c,$66,$7e,$60,$3c,$00 ; e
db $1c,$30,$7c,$30,$30,$30,$30,$00 ; f
db $00,$00,$3e,$66,$66,$3e,$06,$3c ; g
db $60,$60,$7c,$66,$66,$66,$66,$00 ; h
db $18,$00,$18,$18,$18,$18,$0c,$00 ; i
db $0c,$00,$0c,$0c,$0c,$0c,$0c,$78 ; j
db $60,$60,$66,$6c,$78,$6c,$66,$00 ; k
db $18,$18,$18,$18,$18,$18,$0c,$00 ; l
db $00,$00,$ec,$fe,$d6,$c6,$c6,$00 ; m
db $00,$00,$7c,$66,$66,$66,$66,$00 ; n
db $00,$00,$3c,$66,$66,$66,$3c,$00 ; o
db $00,$00,$7c,$66,$66,$7c,$60,$60 ; p
db $00,$00,$3e,$66,$66,$3e,$06,$06 ; q
db $00,$00,$7c,$66,$60,$60,$60,$00 ; r
db $00,$00,$3c,$60,$3c,$06,$7c,$00 ; s
db $30,$30,$7c,$30,$30,$30,$1c,$00 ; t
db $00,$00,$66,$66,$66,$66,$3e,$00 ; u
db $00,$00,$66,$66,$66,$3c,$18,$00 ; v
db $00,$00,$c6,$c6,$d6,$fe,$6c,$00 ; w
db $00,$00,$c6,$6c,$38,$6c,$c6,$00 ; x
db $00,$00,$66,$66,$66,$3c,$18,$30 ; y
db $00,$00,$7e,$0c,$18,$30,$7e,$00 ; z
db $0c,$18,$18,$30,$18,$18,$0c,$00 ; {
db $18,$18,$18,$18,$18,$18,$18,$00 ; |
db $30,$18,$18,$0c,$18,$18,$30,$00 ; }
db $00,$76,$dc,$00,$00,$00,$00,$00 ; ~
db $00,$00,$00,$00,$00,$00,$00,$00

