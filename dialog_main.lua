--
-- Created by IntelliJ IDEA.
-- User: sabareesan_08843
-- Date: 11/21/2017
-- Time: 11:20 AM
-- To change this template use File | Settings | File Templates.

----------------Do not make any changes to this file-------------

SUB_TOPIC_STRING= "+/"..Dialog.DEVICE_SERIAL.."/"..Dialog.DEVICE_BRAND.."/"..Dialog.DEVICE_TYPE.."/"..Dialog.DEVICE_VERSION.."/sub"

Dialog.init= function(callback)
    Dialog.wifi()
end

--Setting Up the Broker--
Dialog.Mqtt.setup_broker= function()
    print("setting up mqtt client")
    mclient = mqtt.Client(Dialog.DEVICE_SERIAL,Dialog.Mqtt.keepalive)
    --setting up MQTT callback functions--
    mclient:on("connect", function(client)
             print ("reconnected to broker")
    end)
    mclient:on("offline", function(client)
            print("broker went offline")
            if(wifi.sta.status()==wifi.STA_GOTIP) then
                mclient:close()
                Dialog.Mqtt.setup_broker()
            end
    end)
    mclient:on("message", function(client, topic, data)
        if data ~= nil then
            print("message Received for Topic: "..topic)
            print("message: " ..data)
            callback_function(data)
        end
    end)
    tmr.delay(4*10^6)
    Dialog.Mqtt.subscribe()
end

--BROKER CONNECT & SUBSCRIBE--
Dialog.Mqtt.subscribe= function()
    print ("connecting to broker....")
    mclient:connect(Dialog.Mqtt.server_ip,Dialog.Mqtt.server_port,0,function(client)
        print ("successfully connected to broker")
        if(SUB_TOPIC_STRING~=nil) then
            print("subscribing to " .. SUB_TOPIC_STRING)
            mclient:subscribe(SUB_TOPIC_STRING,0,function(client) print("subscribe success") dofile("dialog_pubsub.lc") end)
        end
    end, function(client, reason)
        if(wifi.sta.status()==wifi.STA_GOTIP) then
            print("client connection fail code:"..reason)
            mclient:close()
            Dialog.Mqtt.setup_broker()
        end
    end)
end

--PUBLISH--
Dialog.Mqtt.publish= function(EVENT_TOPIC,message)
    if(wifi.sta.status()==wifi.STA_GOTIP ) then
        print("publishing to ".. EVENT_TOPIC ..": ".. message)
        mclient:publish(EVENT_TOPIC, message, 0,0,function(client) print("publish success") end)	-- publish
    else print("publish error")
    end
end

--WiFi--
Dialog.wifi= function()
    print("connecting to "..Dialog.Wifi.ssid..".....")
    wifi.setmode( wifi.STATION)
    wifi.sta.config(Dialog.Wifi)

    --setting up callbacks for WiFi--
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function()
        print ("disconnected from "..Dialog.Wifi.ssid)
        tmr.delay(4*10^6)
        Dialog.wifi()
    end)

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
        print("connected to '"..Dialog.Wifi.ssid.."' with ip: "..wifi.sta.getip())
        Dialog.Mqtt.setup_broker()
    end)
end

