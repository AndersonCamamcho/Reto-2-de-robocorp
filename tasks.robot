*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF


*** Variables ***
${URL}                      https://robotsparebinindustries.com/#/robot-order
${CSV_URL}                  https://robotsparebinindustries.com/orders.csv
${CSV_FILE}=                orders.csv



*** Tasks ***
Ordenar robots
    
    Abrir pagina
    ${Tabla}=    Descargar archivo csv
    FOR    ${orden}    IN    @{Tabla}
        Aceptar el pop up
        Rellenar campos    ${orden}        
        ${Screenshot}=    Tomar screenshot del robot    ${orden}[Order number]
        Sleep    3s
        ${Recibo}=    Guardar recibo HTML en un PDF    ${orden}[Order number]
        Insertar datos de orden y caputura en un pdf    ${Screenshot}    ${Recibo}
        Ordenar otro robot
    
    END



*** Keywords ***
Abrir pagina
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order  
    Maximize Browser Window   
Aceptar el pop up
    Wait Until Element Is Visible    //button[text()='OK']
    Click Button    //button[text()='OK']

Descargar archivo csv
    Download    ${CSV_URL}
    ${lista_de_ordenes}=    Read table from CSV    ${CSV_FILE}    header=True 
    RETURN  ${lista_de_ordenes}
    
Rellenar campos
    
    [Arguments]    ${orden}
    Select From List By Value    id:head    ${orden}[Head]
    Select Radio Button    body    ${orden}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orden}[Legs]
    Input Text    id:address    ${orden}[Address]
    

Tomar screenshot del robot
    [Arguments]    ${numero_de_orden}  
    Click Button    //button[@id='preview'] 
    Wait Until Element Is Visible    id:robot-preview-image  
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}Screenshots${/}Screenshot_${numero_de_orden}.png
    [Return]    ${OUTPUT_DIR}${/}Screenshots${/}Screenshot_${numero_de_orden}.png

Enviar orden
    Click Button    css:button[id="order"]
    Element Should Be Visible    id:receipt
    Element Should Be Visible    id:order-completion

Esperar por la orden
    Wait Until Keyword Succeeds
    ...    10x
    ...    0.1s
    ...    Enviar orden  

Guardar recibo HTML en un PDF
    [Arguments]    ${Numero_de_orden}
    Wait Until Element Is Enabled    id:order
    Click Button    id:order
    Sleep    2
    ${Recibo_HTML}=    Get Element Attribute    receipt   outerHTML
    Html To Pdf    ${Recibo_HTML}    ${OUTPUT_DIR}${/}Recibos${/}Numero_de_orden${Numero_de_orden}.pdf 
    [Return]    ${OUTPUT_DIR}${/}Recibos${/}Numero_de_orden${Numero_de_orden}.pdf 


Insertar datos de orden y caputura en un pdf
    [Arguments]    ${Screenshot}    ${Recibo}
    Open Pdf    ${Recibo}  
    Add Watermark Image To Pdf    ${Screenshot}    ${Recibo}    
    Close Pdf  

Ordenar otro robot
    Click Button    id:order-another

    

    
    
    





