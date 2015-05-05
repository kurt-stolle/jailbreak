-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################


local randomQuestions = {
	{ // Questions about the Jail Break gamemode
		{question="Who created the first version of Jail Break for Garry's Mod?",answer="excl"},
		{question="What does LR stand for?",answer="last request"},
		{question="Who is the person in charge of the prison?",answer="warden"},
	},
	{ // Questions about internet culture, games, etc...
		{question="In the game ‘Metal Gear Solid’,who is the twin brother of Solid Snake?",answer="Liquid Snake"},
		{question="In video gaming, what is the name of the princess whom Mario repeatedly stops Bowser from kidnapping?",answer="Princess Peach"},
		{question="In the game ‘Mortal Kombat’, what phrase is heard when Scorpion uses his spear?",answer="Get over here"},
		{question="What is the name of the gang member that video game ‘Grand Theft Auto: San Andreas’ revolves around?",answer="CJ"},
		{question="How many rows of aliens are there usually at the start of a ‘Space Invaders’ game?",answer="5"},
		{question="How many square blocks is each game piece composed of in the game of ‘Tetris’?",answer="4"},
		{question="What is the name of the fictional English archaeologist in the game ‘Tomb Raider’?",answer="Lara Croft"},
		{question="In the game ‘Doom’, which planet is the space marine posted to after assaulting his commanding officer?",answer="Mars"},
		{question="Which Playstation 2 game, released in 2003, was banned by several countries and implicated by the media in a murder, due to its graphic violence?",answer="Manhunt"},
		{question="Which 1997 Playstation game’s opening song is a Chemical Brothers remix of the Manic Street Preachers song ‘Everything Must Go’?",answer="Gran Turismo"},
		{question="Which 1986 Nintendo game is set in the fantasy land of Hyrule, and centres on a boy named Link?",answer="Zelda"},
		{question="In video games, what colour is Pac-Man?",answer="yellow"},
		{question="‘Black Ops’ is the subtitle of which game?",answer="Call of Duty"},
		{question="Pikachu is one of the species of creatures in which series of games?",answer="Pokemon"},
		{question="Jumpman’s goal is to save the Lady from the giant ape in which 1981 arcade game?",answer="Donkey Kong"},
		{question="The Covenant are fictional military alien races in which game series?",answer="Halo"},
		{question="What color is the most autistic video game hedgehog?",answer="blue"},
	},
	{ // Questions about human subjects, such as history and geography 
		{question="Name a game in which two teams kick a ball around.",answer="football"},
		{question="Who wrote Julius Caesar, Macbeth and Hamlet?",answer="Shakespeare"},
		{question="When was Elvis' first ever concert?",answer="1954"},
		{question="In which city is Hollywood?",answer="Los Angeles"},
		{question="Who was the director of the film 'Psycho'?",answer="Hitchcock"},
		{question="What's the smallest country in the world?",answer="Vatican City"},
		{question="What's the capital of Finland?",answer="Helsinki"},
		{question="How many legs has a spider got?",answer="8"},
	},
	"mathproblem"
};

local question,answer;

_RTN_RUNSTRING_JB_LR_TRIVIA_QUESTION = 0;

local winner_found = false;
local LR = JB.CLASS_LR();
LR:SetName("Trivia");
LR:SetDescription("After the countdown, a random question about a random subject will be asked. The first person to answer this question correctly in chat will win the last request, the loser will be killed.");
LR:SetStartCallback(function(prisoner,guard)
	local subject = randomQuestions[math.random(1,#randomQuestions)];
	
	if type("subject") == "string" and subject == "mathproblem" then
		local operationsFirst = {" + "," - "};
		local operationsSecond = {" * "};

		question=tostring(math.random(1,10));

		local typ = math.random(1,4);
		if typ == 1 or typ == 2 then
			question=question..table.Random(operationsFirst)..tostring(math.random(1,10));
		end

		local div = 0;

		if typ == 2 or typ == 3 or typ == 4 then
			div = math.random(1,10);
			question=question..table.Random(operationsSecond)..(typ == 4 and "( " or "")..tostring(div);
		end

		if typ == 3 then
			question=question..table.Random(operationsSecond)..tostring(math.random(1,10))
		elseif typ == 4 then
			local sec = math.random(-10,10);
			if div-sec == 0 then
				sec = sec+math.random(1,5);
			end
			question=question..table.Random(operationsFirst)..sec.." )";
		end

		RunString("_RTN_RUNSTRING_JB_LR_TRIVIA_QUESTION = "..question..";");
		answer = _RTN_RUNSTRING_JB_LR_TRIVIA_QUESTION;
		question=question.." = "
		
	elseif type(subject) == "table" then
		local rnd = table.Random(subject);
		question = rnd.question; // TODO: add more questions
		answer = rnd.answer;
	end

	winner_found = false;

	net.Start("JB.LR.Trivia.SendQuestion");
	net.WriteString(question);
	net.Broadcast();
end) 

LR:SetSetupCallback(function(prisoner,guard)
	net.Start("JB.LR.Trivia.SendPrepare");
	net.WriteEntity(prisoner);
	net.WriteEntity(guard);
	net.Broadcast();

	return false; // don't halt setup
end)

LR:SetIcon(Material("icon16/rosette.png"))

local id = LR();

if SERVER then
	util.AddNetworkString("JB.LR.Trivia.SendQuestion");
	util.AddNetworkString("JB.LR.Trivia.SendPrepare");
	util.AddNetworkString("JB.LR.Trivia.SendWinner");

	hook.Add( "PlayerSay", "JB.PlayerSay.LR.Trivia", function( ply, text, team )
		if JB.LastRequest == id and table.HasValue(JB.LastRequestPlayers,ply) and string.find(string.lower(text),string.lower(answer)) and not winner_found then
			timer.Simple(0,function()
				net.Start("JB.LR.Trivia.SendWinner");
				net.WriteEntity(ply);
				net.Broadcast();
			end);

			for k,v in ipairs(JB.LastRequestPlayers)do
				if IsValid(v) and v ~= ply then
					v:Kill();
				end
			end
			winner_found = true;
		end
	end )
elseif CLIENT then
	hook.Add("PlayerBindPress", "JB.PlayerBindPress.LR.TriviaNoSayBindsFuckYou", function(pl, bind, pressed) // Not the safest way, but it requires the least amount of touching code outside of this file (without using nasty hacky methods)
		if JB.LastRequest == id and table.HasValue(JB.LastRequestPlayers,pl) and string.find( bind,"say" ) then
			return true;
		end
	end)

	net.Receive("JB.LR.Trivia.SendPrepare",function()
		local guard,prisoner = net.ReadEntity(),net.ReadEntity();

		if not JB.Util.isValid(guard,prisoner) then return end

		chat.AddText( JB.Color["#bbb"], "Quizmaster", JB.Color.white, ": Hello ", guard, JB.Color.white, " and ", prisoner, JB.Color.white, ", prepare to give your answer via chat." );
		timer.Simple(2,function()
			chat.AddText( JB.Color["#bbb"], "Quizmaster", JB.Color.white, ": The first person to answer correctly will win this game of Trivia." );
		end);
	end);
	net.Receive("JB.LR.Trivia.SendQuestion",function()
		local question = net.ReadString() or "ERROR";
		chat.AddText( JB.Color["#bbb"], "Quizmaster", JB.Color.white, ": "..question );
	end);
	net.Receive("JB.LR.Trivia.SendWinner",function()
		local winner = net.ReadEntity();

		if not IsValid(winner) then return end

		chat.AddText( JB.Color["#bbb"], "Quizmaster", JB.Color.white, ": That is correct! ", winner, JB.Color.white, " wins." );
	end);	
end