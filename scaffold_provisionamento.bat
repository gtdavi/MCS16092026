@echo off
setlocal enabledelayedexpansion

REM ===================================================================
REM  SCAFFOLD - provisionamento.bat
REM  Aula 07 - Provisionamento e Automacao de Instalacao
REM
REM  Este arquivo NAO tem codigo pronto - so o roteiro em comentarios.
REM  Cada linha indica qual Peca usar naquele ponto (ver slides/README).
REM  Substituam os comentarios pelo codigo real, mantendo a ordem.
REM ===================================================================

REM 1) Variaveis + cabecalho no log (Pecas 1, 2, 4)

set LOGFILE=log_%COMPUTERNAME%.txt
echo Inicio: %DATE% %TIME% > %LOGFILE%

set apps=GIMP.GIMP TheDocumentFoundation.LibreOffice 7zip.7zip
set ok_count=0
set fail_count=0

REM 2) [se precisar] Verificar Admin (Peca 7)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] O scrip NAO foi executado como Administrador. >> %LOGFILE%
    echo Precisa ser Admin.
    pause
    exit /b 1
) else (
    echo [INFO] Script rodando como Administrador. >> %LOGFILE%
)

REM 3) for em "apps" (Peca 2):
REM    - instalar / [ja instalado? Peca 8] / [tentar de novo Peca 9]
REM    - if/else + contadores + log (Pecas 3, 4, 5)

for %%A in (%apps%) do (
    echo Analisando %%A...

    winget list --id %%A --exact >nul 2>&1
    
    if !errorlevel! equ 0 (
        echo [IDEMPOTENCIA] %%A ja esta instalado. Ignorando a instalacao. >> %LOGFILE%
        set /a ok_count+=1
    ) else (
        echo Instalando %%A...
        winget install --id %%A -e --silent --accept-package-agreements --accept-source-agreements

        if !errorlevel! neq 0 (
            echo [FALHA] Falha ao instalar %%A >> %LOGFILE%
            set /a fail_count+=1
        ) else (
            echo [OK] %%A instalado com sucesso >> %LOGFILE%
            set /a ok_count+=1
        )
    )
)

REM 4) Resumo final no log

echo Fim: %DATE% %TIME% >> %LOGFILE%
echo Sucesso(ou ignorados): !ok_count! ^| Falhas: !fail_count! >> %LOGFILE%
echo Script concluído! Verifique os logs :) %LOGFILE.

REM 5) [se precisar] os dois requisitos do grupo
REM Eu adicionei o conceitos de idempotencia e verificacao de privilegio nas partes 2 e 3 do codigo :)

pause
