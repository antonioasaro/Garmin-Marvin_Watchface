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
    var round = 0;
         
    function initialize() {
        WatchFace.initialize();
        var devSettings = Sys.getDeviceSettings();
        if (devSettings.screenShape == Sys.SCREEN_SHAPE_ROUND) { round = 26; }
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
            
        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour; 
        var mins = clockTime.min; 
        if (hour > 12) { hour = hour - 12; }
        var timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
        var timefgView = View.findDrawableById("id_timefg");
        var timebgView = View.findDrawableById("id_timebg");
        timefgView.setFont(font);
        timebgView.setFont(font);
        timefgView.setText(timeString);   
        timebgView.setText(timeString);    
    
	 	var activity= AttMon.getInfo();
	 	var steps = activity.steps;
        var stepsView = View.findDrawableById("id_steps");
        stepsView.setText(steps.toString());

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        var TracerBitmap;
        var xpos, ypos;
        if (mins == 0) { mins = 60; }
        for (var i = 1; i <= mins; i++) {
            xpos = 94 + i; ypos = (136 + round) - sinx[i % (360/30)];
            if (i == mins) {
                if (mins == 60) { 
                    TracerBitmap = Ui.loadResource(Rez.Drawables.ExplosionIcon);
                    dc.drawBitmap(xpos, 122 + round, TracerBitmap);
                } else {
                    dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
                    dc.drawLine(xpos-4, ypos+0, xpos+4, ypos);
                    dc.drawLine(xpos+0, ypos-4, xpos+0, ypos+4);
                    dc.drawLine(xpos-4, ypos-4, xpos+4, ypos+4);
                    dc.drawLine(xpos-4, ypos+4, xpos+4, ypos-4);
                }
            } else {
                dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
                dc.fillRectangle(xpos, ypos, 1, 1);
	 	    }
        }

        var BTstatusBitmap;
        var devSettings = Sys.getDeviceSettings();
        if (devSettings.phoneConnected) { 
	 		BTstatusBitmap = Ui.loadResource(Rez.Drawables.ConnectIcon);
        } else {
	 		BTstatusBitmap = Ui.loadResource(Rez.Drawables.DisconnectIcon);
	 	}
	 	var btstatusView = View.findDrawableById("id_btstatus");
        dc.drawBitmap(btstatusView.locX, btstatusView.locY, BTstatusBitmap);
	 	
        var stats = Sys.getSystemStats(); 
        var battery = stats.battery;
        dc.setColor(0x444444, Gfx.COLOR_TRANSPARENT);
        var xoff = -4; var yoff = -5 + round;
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
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
