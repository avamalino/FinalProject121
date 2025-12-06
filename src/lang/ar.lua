local function rtl(s)
    return string.reverse(s)
end

return {
    rooms = {
        room1 = {
            controls = rtl("طريقة التحكم:\nالأسهم/WASD - حركة\nمسافة - تفاعل\nZ - تراجع\nI - الجرد"),
            inventory = rtl("الجرد"),
            pickup = rtl("التقاط"),
        },
        room2 = {
            controls = rtl("طريقة التحكم:\nالأسهم/WASD - حركة\nمسافة - تفاعل\nZ - تراجع\nI - الجرد"),
        },
        room3 = {
            controls = rtl("طريقة التحكم:\nالأسهم/WASD - حركة\nمسافة - تفاعل\nZ - تراجع\nI - الجرد"),
        },
        ending = {},
    }
}