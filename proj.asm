title proj.asm
.model small
.stack 100h
.data
    quad_color db ?
    string_bg db ?
    string_fg db ?
    min_width dw ?
    min_height dw ?
    max_width dw ?
    max_height dw ?
    users_fn db "Kenneth", 0dh, 0ah
             db "Dwight", 0dh, 0ah
             db "Kassidy Glean", 0dh, 0ah
             db "Guy Ivan", 0dh, 0ah
             db "Sem Justine", 0dh, 0ah
             db 0
    users_ln db "Arias", 0dh, 0ah
             db "Casanas", 0dh, 0ah
             db "Javier", 0dh, 0ah
             db "Pajo", 0dh, 0ah
             db "Uy", 0dh, 0ah
             db 0
    users_mn db "Bocatija", 0dh, 0ah
             db "Emralino", 0dh, 0ah
             db "Mendez", 0dh, 0ah
             db "user4", 0dh, 0ah
             db "Medina", 0dh, 0ah
             db 0
    users_sn db "2011674", 0dh, 0ah
             db "2420064", 0dh, 0ah
             db "2410735", 0dh, 0ah
             db "user4", 0dh, 0ah
             db "2411308", 0dh, 0ah
             db 0
.code
    FillQ1 proc
        mov word ptr [min_width], 0 ; min X (col)
        mov word ptr [min_height], 0; min Y (row)
        mov word ptr [max_width], 159 ; max X (col)
        mov word ptr [max_height], 99 ; max Y (row)
        call QuadFill
        ret
    FillQ1 endp
    FillQ2 PROC
        mov word ptr [min_width], 160 ; min X (col)
        mov word ptr [min_height], 0; min Y (row)
        mov word ptr [max_width], 319 ; max X (col)
        mov word ptr [max_height], 99 ; max Y (row)
        call QuadFill
        ret
    FillQ2 ENDP
    FillQ3 PROC
        mov word ptr [min_width], 0 ; min X (col)
        mov word ptr [min_height], 100; min Y (row)
        mov word ptr [max_width], 159 ; max X (col)
        mov word ptr [max_height], 199 ; max Y (row)
        call QuadFill
        ret
    FillQ3 ENDP
    FillQ4 PROC
        mov word ptr [min_width], 160 ; min X (col)
        mov word ptr [min_height], 100; min Y (row)
        mov word ptr [max_width], 319 ; max X (col)
        mov word ptr [max_height], 199 ; max Y (row)
        call QuadFill
        ret
    FillQ4 ENDP
    QuadFill proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di

        mov si, word ptr [min_height] ; Y_Counter
        row_loop:
        mov cx, word ptr [min_width] ; X_Counter
        col_loop:
        ; Calculate offset = Y_counter * 320 + X_counter
        mov ax, si
        mov bx, 320
        mul bx ; AX = Y_counter * 320
        add ax, cx ; AX = offset
        mov di, ax
        call Draw
        inc cx
        cmp cx, word ptr [max_width] ; X_counter <= X_max
        jle col_loop
        inc si
        cmp si, word ptr [max_height] ; Y Counter <= Y_max
        jle row_loop
        
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    QuadFill endp
    Draw proc
        push ax
        xor ah,ah
        mov al, [quad_color]
        mov byte ptr es:[di], al ; Colorize the location of the pixel
        pop ax
        ret
    Draw endp
    WriteString proc
        push ax bx cx dx si
        cld ; Clear Direction Flag. Prepare to properly increment SI 
        mov bl, 8 ; size dimension of a glyph (8x8 pixels) = size of one text cell
        mov al, byte ptr [min_height] ; Start of the row pixel
        xor ah,ah
        div bl ; Cell's row = pixel's row/8
        mov dh, al
        cmp ah, 0
        je skip_row
        inc dh
        jmp skip_row
        skip_row:
        mov al, byte ptr [min_width] ; Start of the column pixel
        xor ah,ah
        div bl ; Cell's column = pixel's column/8
        mov dl, al
        mov ah, 02h ; Set the final cursor of a cell
        xor bh, bh ; page = 0 Page is for Video Mode
        int 10h
    write_loop:
        lodsb ; Load current bytes from SI to AL, then increment SI
        test al,al ; Is AL non-zero? Set Zero Flag if zero
        jz write_exit ; If byte is 0 (terminator), finish writing
        cmp al, 0dh
        je write_cr ; If byte is carriage return, handle it
        cmp al, 0ah
        je write_lf ; If byte is line feed, handle it
        mov ah, 09h ; VIDEO: Start writing character at the current cursor position (Cell's position)
        mov bh, byte ptr [string_bg] ; Background color of a char
        mov bl, byte ptr [string_fg] ; Foreground color of a char
        mov cx, 1 ; Write it once
        int 10h
        inc dl ; Prepare to set the next position to the next column
        mov ah, 02h
        xor bh, bh ; page = 0 Page is for Video Mode
        int 10h
        jmp write_loop ; GO to the next iteration
    write_cr:
        jmp write_loop ; Skip carriage return
    write_lf:
        inc dh ; Go to the next row
        xor ax, ax
        mov bl, 8 ; Do calculation for column
        mov al, byte ptr [min_width] ; Reset column (because carriage)
        div bl
        mov dl, al
        mov ah, 02
        xor bh, bh
        int 10h ; Set the position
        jmp write_loop ; Go to the next iteration
    write_exit:
        pop si dx cx bx ax
        ret
    WriteString endp
    ; ---------- MAIN ENTRY ---------- ;
    Main:
        ; --- SETUP --- ;
        mov ax, @data
        mov ds, ax
        mov ax, 0013h ; 00h=SET-MODE:13h VGA (320x200)W*H (x,y)
        int 10h
        mov ax, 0a000h ; Set Video mem segment to Extended Segment
        mov es, ax
        mov byte ptr [quad_color], 40 ; Red
        mov byte ptr [string_bg], 40
        mov byte ptr [string_fg], 48
        call FillQ1 ; Red Q1
        lea si, users_sn ; Load variable address from data segment to source index
        call WriteString ; Write string on top of the quadrant
        mov byte ptr [quad_color], 32 ; Blue
        mov byte ptr [string_bg], 32
        mov byte ptr [string_fg], 44
        call FillQ2 ; Blue Q2
        lea si, users_fn
        call WriteString
        mov byte ptr [quad_color], 48 ; Green
        mov byte ptr [string_bg], 48
        mov byte ptr [string_fg], 40
        call FillQ3 ; Green Q3
        lea si, users_mn
        call WriteString
        mov byte ptr [quad_color], 44 ; Yellow
        mov byte ptr [string_bg], 44
        mov byte ptr [string_fg], 32
        call FillQ4 ; Yellow Q4
        lea si, users_ln
        call WriteString
        xor ah, ah ; Set to 0
        int 16h ; Wait for entry
        mov ax, 0003h ; 00h=SET-Mode:03h TEXT
        int 10h
        mov ax, 4c00h ; Exit
        int 21h
end Main