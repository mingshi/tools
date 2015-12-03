" Template Tookit (TT2, Perl)
au BufNewFile,BufRead *.tt2,*.tt,*.tt.html,*.tt2.html call AdjustTT2Type()

func! AdjustTT2Type()
    setf tt2html
    let b:tt2_syn_tags = '\[% %] <!-- -->'

    " adding some XML features, also
    runtime ftplugin/xml.vim

    let l1 = getline(1)
    let l2 = getline(2)
    let l3 = getline(3)

    if l1 =~ '<\chtml' || l2 =~ '<\chtml' || l3 =~ '<\chtml' && l1 !~ '<[%?]' || l2 !~ '<[%?]' || l3 !~ '<[%?]' || l1 =~ '<!DOCTYPE HTML'
      setf tt2html
    else
      setf tt2
    endif
endfunc

autocmd BufNewFile,BufRead *.tx setfiletype xslate
autocmd BufNewFile,BufRead *.html if search('^: ') > 0 | set filetype=xslate | endif

autocmd BufNewFile,BufRead *.psgi setfiletype perl
