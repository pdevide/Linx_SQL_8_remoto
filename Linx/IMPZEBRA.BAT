@ECHO OFF

NET USE LPT2 /DELETE
NET USE LPT2 \\%CLIENTNAME%.CCP.CAEDU\ZEBRA3 /PERSISTENT:YES

ECHO ************************************************************************** >> C:\TEMP\MAPEAMENTO.LOG
ECHO NOME DO COMPUTADOR=%COMPUTERNAME% 								    >> C:\TEMP\MAPEAMENTO.LOG
NET USE 																    >> C:\TEMP\MAPEAMENTO.LOG
ECHO ************************************************************************** >> C:\TEMP\MAPEAMENTO.LOG

:: NET USE LPT2 /DELETE
:: NET USE LPT2 \\%CLIENTNAME%.CCP.CAEDU\ZEBRA3 /PERSISTENT:YES

