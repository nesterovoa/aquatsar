--
-- Created by IntelliJ IDEA.
-- User: RJ
-- Date: 25/01/2018
-- Time: 09:20
-- To change this template use File | Settings | File Templates.
--

--
-- Edit by Notepad++.
-- User: iBrRus
-- Date: 01/12/2020
-- Time: 22:18
--

ISBoatMechanicsOverlay = {};
ISBoatMechanicsOverlay.BoatList = {};
ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"] = {imgPrefix = "salingboat_", x=10,y=-30};

ISBoatMechanicsOverlay.PartList = {};
ISBoatMechanicsOverlay.PartList["Battery"] = {img="battery", vehicles={}};
ISBoatMechanicsOverlay.PartList["Battery"].vehicles["salingboat_"] = {x=50+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=96+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=93+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=126+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};
ISBoatMechanicsOverlay.PartList["Engine"] = {img="engine", vehicles = {}};
ISBoatMechanicsOverlay.PartList["Engine"].vehicles["salingboat_"] = {x=5+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=500+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=86+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=550+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["GasTank"] = {img="gastank", vehicles = {}};
ISBoatMechanicsOverlay.PartList["GasTank"].vehicles["salingboat_"] = {x=146+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=500+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=255+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=550+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["HeadlightLeft"] = {img="headlight_left", vehicles = {}};
ISBoatMechanicsOverlay.PartList["HeadlightLeft"].vehicles["salingboat_"] = {x=103+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=260+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=112+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=277+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["HeadlightRight"] = {img="headlight_right", vehicles = {}};
ISBoatMechanicsOverlay.PartList["HeadlightRight"].vehicles["salingboat_"] = {x=150+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=260+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=159+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=277+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["WindowFrontLeft"] = {img="window_front_left", vehicles = {}};
ISBoatMechanicsOverlay.PartList["WindowFrontLeft"].vehicles["salingboat_"] = {x=84+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=289+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=92+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=304+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["WindowFrontRight"] = {img="window_front_right", vehicles = {}};
ISBoatMechanicsOverlay.PartList["WindowFrontRight"].vehicles["salingboat_"] = {x=169+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=289+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=178+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=304+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["WindowRearLeft"] = {img="window_rear_left", vehicles = {}};
ISBoatMechanicsOverlay.PartList["WindowRearLeft"].vehicles["salingboat_"] = {x=79+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=320+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=87+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=340+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["WindowRearRight"] = {img="window_rear_right", vehicles = {}};
ISBoatMechanicsOverlay.PartList["WindowRearRight"].vehicles["salingboat_"] = {x=174+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=320+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=182+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=340+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};

ISBoatMechanicsOverlay.PartList["Windshield"] = {img="window_windshield", vehicles = {}};
ISBoatMechanicsOverlay.PartList["Windshield"].vehicles["salingboat_"] = {x=120+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y=214+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y,x2=140+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].x,y2=237+ISBoatMechanicsOverlay.BoatList["Base.SailingBoat"].y};



