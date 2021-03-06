using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Timer as Timer;
using Toybox.ActivityMonitor as AttMon;

class Marvin_WatchfaceView extends Ui.WatchFace {
    var font;
    var sinx = [-1, -4, -8, -10, -8, -4, 1, 4, 8, 10, 8, 4];
    var cosx = [-1, -2, -4, -5,  -4, -2, 1, 2, 4, 5,  4, 2];
    var round = 0;
    var rectangle = 0;
    var tall = 0;
    var devSettings;
    var deviceName;
    var showSeconds;
    var secsView;
         
    function initialize() {
        WatchFace.initialize();
        showSeconds = true;
        deviceName = Ui.loadResource(Rez.Strings.deviceName);
        Sys.println("Antonio - initialize with deviceName: " + deviceName);
        if (deviceName.equals("round"))      { round     = 26;  }
        if (deviceName.equals("rectangle"))  { rectangle = -18; }
        if (deviceName.equals("tall"))       { tall      = 14;   }
    }

    // Load your resources here
    function onLayout(dc) {
        font = Ui.loadResource(Rez.Fonts.id_font);
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        Sys.println("Antonio - onUpdate");
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
        var dateView = View.findDrawableById("id_date");
        dateView.setText(dateString);

        devSettings = Sys.getDeviceSettings();            
        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour; 
        var mins = clockTime.min; 
        var secs = clockTime.sec;
        var secsString = Lang.format("$1$", [clockTime.sec.format("%02d")]);

        if (!devSettings.is24Hour) {
            if (hour > 12) { hour = hour - 12; }
            if (hour == 0) { hour = 12; }
        } 
        var timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
        var timefgView = View.findDrawableById("id_timefg");
        var timebgView = View.findDrawableById("id_timebg");
        secsView = View.findDrawableById("id_secs");
        timefgView.setFont(font);
        timebgView.setFont(font);
        timefgView.setText(timeString);   
        timebgView.setText(timeString);    
    
	 	var activity= AttMon.getInfo();
	 	var steps = activity.steps;
        var stepsView = View.findDrawableById("id_steps");
        stepsView.setText(steps.toString());

//////////////////////////////////////////
//		timeString = "12:34";
//		mins=0;


        // Call the parent onUpdate function to redraw the layout
        if (showSeconds != true) { secsView.setColor(Gfx.COLOR_TRANSPARENT); }   
        View.onUpdate(dc);
        var TracerBitmap;
        var xpos, ypos, tpos, tclr, xoff, yoff;
        if (showSeconds == true) { tpos = secs; } else { tpos = mins; }
        if (showSeconds == true) { tclr = Gfx.COLOR_BLUE; } else { tclr = Gfx.COLOR_RED; }
        if (tpos == 0) { tpos = 60; }
        for (var i = 1; i <= tpos; i++) {
//            secsView.setColor(Gfx.COLOR_TRANSPARENT);   
            if (showSeconds == true) { yoff = cosx[i % (360/30)]; } else { yoff = sinx[i % (360/30)]; }
            xpos = 94 + i - 2*tall; ypos = (136 + round + rectangle + tall + tall/2) - yoff;
            if (i == tpos) {
                if (tpos == 60) { 
                    if (showSeconds == true) { 
                        TracerBitmap = Ui.loadResource(Rez.Drawables.ExplosionBlueIcon); 
                    } else {
                        TracerBitmap = Ui.loadResource(Rez.Drawables.ExplosionRedIcon);
                    }
                    dc.drawBitmap(xpos - tall/2, 122 + round + rectangle + tall + tall/2, TracerBitmap);
                } else {
                    if (showSeconds == true) {
                        if (secs < 59) {
                            secsView.setText(secsString); 
                            secsView.setLocation(xpos-6, ypos-8);
                            secsView.setColor(Gfx.COLOR_BLUE);
                        } else {
                            secsView.setColor(Gfx.COLOR_TRANSPARENT);
                        }  
                    } else {
                        dc.setColor(tclr, Gfx.COLOR_TRANSPARENT);
                        dc.drawLine(xpos-4, ypos+0, xpos+4, ypos);
                        dc.drawLine(xpos+0, ypos-4, xpos+0, ypos+4);
                        dc.drawLine(xpos-4, ypos-4, xpos+4, ypos+4);
                        dc.drawLine(xpos-4, ypos+4, xpos+4, ypos-4);
                    }
                }
            } else {
                dc.setColor(tclr, Gfx.COLOR_TRANSPARENT);
                dc.fillRectangle(xpos, ypos, 1, 1);
	 	    }
        }

        var BTstatusBitmap;
        if (devSettings.phoneConnected) { 
	 		BTstatusBitmap = Ui.loadResource(Rez.Drawables.ConnectIcon);
        } else {
	 		BTstatusBitmap = Ui.loadResource(Rez.Drawables.DisconnectIcon);
	 	}
	 	var btstatusView = View.findDrawableById("id_btstatus");
        dc.drawBitmap(btstatusView.locX, btstatusView.locY, BTstatusBitmap);

        var alarmBitmap;
        if (devSettings.alarmCount > 0) {
            Sys.println("Antonio - onUpdate: alarmCount");
	 		alarmBitmap = Ui.loadResource(Rez.Drawables.AlarmIcon);
            dc.drawBitmap(btstatusView.locX+10+9, btstatusView.locY-1, alarmBitmap);
        }
        
	 	
        var stats = Sys.getSystemStats(); 
        var battery = stats.battery;
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        xoff = -5 - tall/4 + rectangle/4; yoff = -5 + round + rectangle/2 + tall/2;
        if (battery <= 100) { dc.drawText(24+xoff, 90+yoff, Gfx.FONT_SYSTEM_XTINY, battery.format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER); }
        if (battery <= 100) { dc.setColor(Gfx.COLOR_GREEN,  Gfx.COLOR_TRANSPARENT); }
        if (battery <= 75)  { dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT); }
        if (battery <= 50)  { dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT); }
        if (battery <= 25)  { dc.setColor(Gfx.COLOR_RED,    Gfx.COLOR_TRANSPARENT); }
        dc.fillRectangle(15+xoff, 63+yoff, 10, 3);
        dc.fillRectangle(13+xoff, 66+yoff, 14, 25);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(15+xoff, 68+yoff, 10, (20 * (100 - battery)) / 100);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        Sys.println("Antonio - onExitSleep");
        showSeconds = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        Sys.println("Antonio - onEnterSleep");
        showSeconds = false;
        Ui.requestUpdate();
    }

}
