*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.HTTP


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        #    Preview the robot
        #    Submit the order
        #    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        #    ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        #    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        #    Go to order another robot
    END
    # Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Filter empty rows    ${orders}
    RETURN    ${orders}

Close the annoying modal
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    id-body-${order}[Body]
    Input Text    xpath:    ${order}[Legs]
    Input Text    address    ${order}[Address]
