transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Aluno/Downloads/MatheusMarques_GrabrielPadovani_Pratica1/TP1/Parte\ 1\ e\ 2 {C:/Users/Aluno/Downloads/MatheusMarques_GrabrielPadovani_Pratica1/TP1/Parte 1 e 2/ramlpm.v}
vlog -vlog01compat -work work +incdir+C:/Users/Aluno/Downloads/MatheusMarques_GrabrielPadovani_Pratica1/TP1/Parte\ 1\ e\ 2 {C:/Users/Aluno/Downloads/MatheusMarques_GrabrielPadovani_Pratica1/TP1/Parte 1 e 2/parte_1.v}

