--
-- Created by IntelliJ IDEA.
-- User: sabareesan_08843
-- Date: 11/21/2017
-- Time: 11:20 AM
-- To change this template use File | Settings | File Templates.
--

----------------No need to make any changes to this file-------------

Dialog = {}
Dialog.Mqtt={}
Dialog.Wifi = {}
Dialog.actions={}

if (file.exists("dialog_main.lua") and file.exists("dialog_pubsub.lua")) then
    node.compile("dialog_main.lua")
    node.compile("dialog_pubsub.lua")
    file.remove("dialog_main.lua")
    file.remove("dialog_pubsub.lua")
end

dofile("config.lua")
dofile("dialog_main.lc")
Dialog.init(Dialog.Wifi,callback_function)











