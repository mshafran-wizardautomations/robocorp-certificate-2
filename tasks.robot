*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${url}=    Prompt for order site
    Open the robot order website    ${url}
    ${order_file}=    Read order file from Vault
    ${orders}=    Get orders    ${order_file}
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    5x    3s    Preview the robot
        Wait Until Keyword Succeeds    5x    3s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    Close Browser


*** Keywords ***
Prompt for order site
    Add heading    Request Website URL
    Add text input
    ...    url
    ...    placeholder=https://robotsparebinindustries.com/#/robot-order
    ...    label=Robot order website URL
    ${result}=    Run dialog
    RETURN    ${result.url}

Open the robot order website
    [Arguments]    ${url}
    Open Available Browser    ${url}

Get orders
    [Arguments]    ${order_file}
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Filter empty rows    ${orders}
    RETURN    ${orders}

Close the annoying modal
    Wait and Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${order}
    ${head}=    Set variable    head
    ${body}=    Set variable    body
    ${legs}=    Set variable    css:input[placeholder="Enter the part number for the legs"]
    ${address}=    Set variable    address
    Wait Until Element Is Visible    ${head}
    Wait Until Element Is Visible    ${body}
    Wait Until Element Is Visible    ${legs}
    Wait Until Element Is Visible    ${address}
    Select From List By Value    ${head}    ${order}[Head]
    Select Radio Button    ${body}    id-body-${order}[Body]
    Input Text    ${legs}    ${order}[Legs]
    Input Text    ${address}    ${order}[Address]

Preview the robot
    Wait and Click Button    preview
    Wait Until Element Is Visible    robot-preview-image

Submit the order
    Wait and Click Button    order
    Page Should Contain Element    receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${pdf_file_path}=    Set variable    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf
    Wait Until Element Is Visible    id:order-completion
    ${order_results_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${order_results_html}    ${pdf_file_path}
    RETURN    ${pdf_file_path}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${pdf_file_path}=    Set variable    ${OUTPUT_DIR}${/}robots${/}${order_number}.png
    Screenshot    robot-preview-image    ${pdf_file_path}
    RETURN    ${pdf_file_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    @{files}=    Create List    ${screenshot}
    Open Pdf    ${pdf}
    Add Files To Pdf    ${files}    ${pdf}    append=True
    #Close Pdf    ${pdf} - doesn't let me close for some reason.. need to check if add files to pdf closes it automatically

Go to order another robot
    Wait and Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}/receipts.zip

Read order file from Vault
    ${secret}=    Get Secret    sample
    RETURN    ${secret}[order_file]
