﻿package com.ankamagames.dofus.console
{
    import com.ankamagames.jerakine.console.ConsoleInstructionRegistar;
    import com.ankamagames.dofus.datacenter.communication.Emoticon;
    import com.ankamagames.dofus.console.chat.InfoInstructionHandler;
    import com.ankamagames.dofus.console.common.LatencyInstructionHandler;
    import com.ankamagames.dofus.console.chat.SocialInstructionHandler;
    import com.ankamagames.dofus.console.chat.MessagingInstructionHandler;
    import com.ankamagames.dofus.console.chat.FightInstructionHandler;
    import com.ankamagames.dofus.console.chat.EmoteInstructionHandler;
    import com.ankamagames.dofus.console.chat.OptionsInstructionHandler;
    import com.ankamagames.dofus.BuildInfos;
    import com.ankamagames.dofus.network.enums.BuildTypeEnum;
    import com.ankamagames.dofus.console.debug.MiscInstructionHandler;
    import com.ankamagames.jerakine.data.I18n;
    import com.ankamagames.dofus.console.chat.StatusInstructionHandler;
    import com.ankamagames.jerakine.console.ConsoleHandler;

    public class ChatConsoleInstructionRegistrar implements ConsoleInstructionRegistar 
    {


        public function registerInstructions(console:ConsoleHandler):void
        {
            var emote:*;
            var emoteShortcuts:Array = new Array();
            for each (emote in Emoticon.getEmoticons())
            {
                emoteShortcuts.push(emote.shortcut);
            };
            console.addHandler(["whois", "version", "about", "whoami", "mapid", "cellid", "time"], new InfoInstructionHandler());
            console.addHandler(["aping", "ping"], new LatencyInstructionHandler());
            console.addHandler(["f", "ignore", "invite"], new SocialInstructionHandler());
            console.addHandler(["w", "whisper", "msg", "t", "g", "p", "a", "r", "b", "m"], new MessagingInstructionHandler());
            console.addHandler(["s", "spectator", "list", "players", "kick"], new FightInstructionHandler());
            console.addHandler(emoteShortcuts, new EmoteInstructionHandler());
            console.addHandler(["tab", "clear"], new OptionsInstructionHandler());
            if (BuildInfos.BUILD_TYPE != BuildTypeEnum.RELEASE)
            {
                console.addHandler(["savereplaylog", "sd", "shieldmax", "shieldmed", "shieldmin"], new MiscInstructionHandler());
            }
            else
            {
                console.addHandler(["savereplaylog", "shieldmax", "shieldmed", "shieldmin"], new MiscInstructionHandler());
            };
            console.addHandler(["away", I18n.getUiText("ui.chat.status.away").toLocaleLowerCase(), I18n.getUiText("ui.chat.status.solo").toLocaleLowerCase(), I18n.getUiText("ui.chat.status.private").toLocaleLowerCase(), I18n.getUiText("ui.chat.status.availiable").toLocaleLowerCase(), "release"], new StatusInstructionHandler());
        }


    }
}//package com.ankamagames.dofus.console

