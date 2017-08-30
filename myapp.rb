require 'rest-client'
require 'sinatra'
require 'json'
require 'http'
require 'faye/websocket'
require 'eventmachine'

before do
  @teams ||= load_data

  begin
    request.body.rewind
    data = JSON.parse request.body.read
    if data["team_id"]
      @team = find_team(@teams, data["team_id"], data["event"]["user"])
    end
  rescue JSON::ParserError
    p "No JSON in body"
  end

end

def find_team(teams, team_id, user_id)
  all_matching_auths = teams.select {|t| t["team_id"] == team_id }
  user_auth = all_matching_auths.detect {|t| t["user_id"] == user_id }
  team = user_auth || all_matching_auths.first

  team ? OpenStruct.new(team) : nil
end
get '/' do
	  'Hello world!'
end

def save(team)
  @teams << team

  File.open("store.json","w") do |file|
    file.write @teams.to_json
  end
end

def load_data
  if FileTest.exist?("store.json")
    JSON.parse(File.read('store.json'))
  else
    []
  end
end

post '/events' do
  request.body.rewind
  data = JSON.parse(request.body.read, object_class: OpenStruct)
  if data["type"] == "url_verification"
    content_type :json
    return {challenge: data["challenge"]}.to_json
  end
    case data.type
	  when "event_callback"
		event = data.event
		if event.subtype && event.subtype == "file_share"
          case event.file.name
            when "desktop.jpeg"
				attachments = [
                {
                 "title": "Hisense Chromebook (11.6\" Quad-Core Processor)",
                 "title_link": "https://www.walmart.com/ip/Hisense-Chromebook-11-6-Quad-Core-Processor/44389793",
                 "image_url": "https://i5.walmartimages.com/asr/123311b1-f24f-4d2c-ab51-1dfc3d9c77f3_1.9431c6c1b3d3e948781e77ccf72dae15.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title":"ADD TO CART",
                 "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D44389793%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Acer CB3-532-C47C 15.6\" Chromebook, Chrome OS, Intel Celeron N3060 Dual-Core Processor, 2GB RAM, 16GB Internal Storage",
                 "title_link": "https://www.walmart.com/ip/Acer-CB3-532-C47C-15-6-Chromebook-Chrome-OS-Intel-Celeron-N3060-Dual-Core-Processor-2GB-RAM-16GB-Internal-Storage/54518466",
                 "image_url": "https://i5.walmartimages.com/asr/1f79d1f4-18cd-4a2a-a3b3-b05161a297b2_1.0766857900119a422e0a9d2844938dcd.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title":"ADD TO CART",
                 "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D54518466%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Refurbished HP Pavilion x360 15-bk020wm 15.6\" Laptop, Touchscreen, 2-in-1, Windows 10 Home, Intel Core i5-6200U Processor, 8GB RAM, 1TB Hard Drive",
                 "title_link": "https://www.walmart.com/ip/Refurbished-HP-Pavilion-x360-15-bk020wm-15-6-Laptop-Touchscreen-2-in-1-Windows-10-Home-Intel-Core-i5-6200U-Processor-8GB-RAM-1TB-Hard-Drive/54946694",
                 "image_url": "https://i5.walmartimages.com/asr/66af0b1e-45ce-440b-bdf0-de0c58aabafa_1.833bc7c1946dd0ada30a1ed3336af7fe.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title":"ADD TO CART",
                 "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D54946694%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Dell Inspiron i355210040BLK 15.6\" Laptop, Windows 10 Home, Intel Pentium N3710 Processor, 8GB RAM, 1TB Hard Drive",
                 "title_link": "https://www.walmart.com/ip/Dell-Inspiron-i355210040BLK-15-6-Laptop-Windows-10-Home-Intel-Pentium-N3710-Processor-8GB-RAM-1TB-Hard-Drive/54748226",
                 "image_url": "https://i5.walmartimages.com/asr/6cd21649-69bf-4bc3-b46d-633d4cbe55e6_1.8fee7db0277425fbb384a80fb40a1c04.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title":"ADD TO CART",
                 "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D54748226%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
        }
    ].to_json
            when "infant_milk.jpeg"
              attachments = [        
                  {
                    "title": "Similac Pro-Advance Infant Formula",
                    "title_link": "https://www.walmart.com/ip/Similac-Pro-Advance-Infant-Formula-with-2-FL-Human-Milk-Oligosaccharide-HMO-for-Immune-Support-23-2-ounces-Pack-of-4/54427941",
                    "image_url": "https://i5.walmartimages.com/asr/4b90f2dc-9d5e-4c5f-af5a-49bac41d01aa_1.77bdf65f715e20f36aa5b4e81233f021.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                  },
                  {
                    "title":"ADD TO CART",
                    "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D54427941%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapihttp://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                  },
                  {
                    "title": "Gerber Good Start Gentle Milk Based Powder",
                    "title_link": "https://www.walmart.com/ip/Gerber-Good-Start-Gentle-Milk-Based-Powder-Infant-Formula-with-Iron-1-Birth-12-Months-12-7-oz/14662909",
                    "image_url": "https://i5.walmartimages.com/asr/119df6f9-3b49-4bc7-b912-ec3b69f14ce7_1.a123916bbeb0886ba42df9bba5f10277.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                  },
                  {
                    "title":"ADD TO CART",
                    "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D14662909%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapihttp://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                  },
                  {
                    "title": "Similac Advance Infant Formula with Iron, Powder, 1.45 lb",
                    "title_link": "https://www.walmart.com/ip/Similac-Advance-Infant-Formula-with-Iron-Powder-1-45-lb/14018007",
                    "image_url": "https://i5.walmartimages.com/asr/168c9137-ade5-4e6d-b931-03d7d8ce52b0_1.f78c2cb3b4f7f332f42f3431486e848c.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                  },
                  {
                    "title":"ADD TO CART",
                    "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D14018007%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapihttp://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                  },
                  {
                    "title": "Pure Bliss by Similac Infant Formula",
                    "title_link": "https://www.walmart.com/ip/Pure-Bliss-by-Similac-Infant-Formula-Starts-with-Fresh-Milk-from-Grass-Fed-Cows-31-8-ounces-Pack-of-4/54430593",
                    "image_url": "https://i5.walmartimages.com/asr/7b37c02a-08f7-4b7e-9bf0-c18f35909542_1.91cef337f6b2d8bccb749a185678be80.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                  },
                  {
                    "title":"ADD TO CART",
                    "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D54430593%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapihttp://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                  }
              ].to_json
          end
        else
          case event.text
            when /^hi|hello|hey.*/
              urls = "Hi! Nice to meet you. I am Ody, the walmart.com shopping assistant! You can paste an url or upload an image here. I will try my best to find the most relevant products for you from walmart.com."
            when "<https://www.babycenter.com/best-convertible-car-seat>"
			  attachments = [
        {			
            "title": "Graco 4Ever All-in-1 Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Graco-4Ever-All-in-1-Convertible-Car-Seat-Choose-Your-Pattern/46335604",
			      "image_url":"https://i5.walmartimages.com/asr/b27da759-3f31-4727-a22f-3d7bc1c41a07_1.02cf3c75fc81a513eed09a662e59266e.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D46335604%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Graco Contender 65 Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Graco-Contender-65-Convertible-Car-Seat-Choose-Your-Pattern/33396182",
			      "image_url":"https://i5.walmartimages.com/asr/328b980a-9762-422a-8f8d-53bf171b3ff5_1.b6eff89073debf58491355b572ef5936.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D33396182%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Diono Radian RXT Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Diono-Radian-RXT-Convertible-Car-Seat-Black-Cobalt/50878012",
			      "image_url":"https://i5.walmartimages.com/asr/0303efbc-d205-4c51-bd39-139af9e831f6_1.939d16a6711f79943f3b21bd347d45d3.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D50878012%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Britax Marathon ClickTight Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Britax-Marathon-ClickTight-Convertible-Car-Seat-Vue/55425979",
			      "image_url":"https://i5.walmartimages.com/asr/61a8921a-b7a9-4401-8492-30a460bae83d_1.b8efebb059f3922398599d3919743129.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D55425979%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"}        
    ].to_json

            when "<http://www.parents.com/fun/entertainment/books/best-childrens-books-of-the-year/>"
              attachments = [
        {			
            "title": "Big Fish Little Fish",
			      "title_link": "https://www.walmart.com/ip/Big-Fish-Little-Fish/49207133",
			      "image_url":"http://images.parents.mdpcdn.com/sites/parents.com/files/styles/width_360/public/102787324.jpg"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D49207133%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "TouchThinkLearn: ABC",
			      "title_link": "https://www.walmart.com/ip/ABC/51797530",
			      "image_url":"https://www.walmart.com/ip/Graco-Contender-65-Convertible-Car-Seat-Choose-Your-Pattern/33396182"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D51797530%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "GOODNIGHT EVERYONE",
			      "title_link": "https://www.walmart.com/ip/GOODNIGHT-EVERYONE/912129766",
			      "image_url":"https://i5.walmartimages.com/asr/10b7cf0a-ebd6-4444-a030-8b93398ac4a2_1.5a608ea2e6bdacc29443ef5b278c2a53.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D912129766%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "The Cookie Fiasco",
			      "title_link": "https://www.walmart.com/ip/The-Cookie-Fiasco/52609219",
			      "image_url":"https://i5.walmartimages.com/asr/c7a3da62-aefe-4176-a6eb-026f93d4005b_1.d9bdfc55775f3018e684afc58e330704.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"Add To Cart", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D52609219%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"}
    ].to_json
            when "<https://www.makeupalley.com/>"
              urls = "check what I've found\nhttps://www.walmart.com/ip/Orly-Bonder-Rubberized-Base-Coat-0-3-oz/227372525\nhttps://www.walmart.com/ip/wet-n-wild-Photo-Focus-Concealer-Wand-Light-Ivory/123328886\nhttps://www.walmart.com/ip/Estee-Lauder-Advanced-Night-Repair-Synchronized-Recovery-Complex-II-75ml-2-5oz/127132304\nhttps://www.walmart.com/ip/Estee-Lauder-Double-Wear-Stay-In-Place-Makeup-SPF-10-No-01-Fresco-2C3-30ml-1oz/152329402"
            when "<https://ezinearticles.com/?cat=Home-Improvement:Furniture>"
              urls = "check what I've found\nhttps://www.walmart.com/ip/Trespass-Marmor-Tufted-Nail-Head-Upholstered-Bed-Queen/43829183\nhttps://www.walmart.com/ip/Best-Choice-Products-Patio-Umbrella-Offset-10-Hanging-Umbrella-Outdoor-Market-Umbrella-New-Multiple-Colors/166312054\nhttps://www.walmart.com/ip/Solis-Ligna-Solid-Wood-Table-and-Bonded-Leather-Office-Chairs-11-piece-Conference-Set/54972176\nhttps://www.walmart.com/ip/Mainstays-Buchannan-Sofa-Dark-Chocolate-Microfiber/47218551"
            when "<https://www.rottentomatoes.com/>"
              urls = "check what I've found\nhttps://www.vudu.com/movies/#!content/850531/Annabelle-Creation\nhttps://www.vudu.com/movies/#!content/864891/Dunkirk-Season-1\nhttps://www.vudu.com/movies/#!content/884936/The-Hitmans-Bodyguard\nhttps://www.vudu.com/movies/#!content/851335/Spider-Man-Homecoming"
            else
              urls = "I don't get it!!"
		  end
		end
	  
      options = {
	  token: @team.bot["bot_access_token"],
	  channel: data["event"]["channel"],
	  text: "Here is what I found:",
	  as_user: false,
	  attachments: attachments
	  }

	  puts "========================" << data.event.bot_id.to_s
	  if !data.event || !data.event.bot_id
        #| data["event"]["bot_id"] != "B6VSYB7TQ"
	    res = RestClient.post 'https://slack.com/api/chat.postMessage', options, content_type: :json
	    p res.body
	  end
  end
  #request.body.rewind
  #data = JSON.parse(request.body.read, object_class: OpenStruct)
  #$teams[data["team_id"]]['client'].chat_update(
  #      as_user: 'true',
  #      channel: data["event"]["channel"],
  #      ts: data["event"]["ts"],
  #      text: SlackTutorial.welcome_text)
  
  #{"text": "I am a test message http://slack.com"}.to_json
  '''puts "so far so good"
  case data.type
  when "url_verification"
    content_type :json
    return {challenge: data["challenge"]}.to_json

  when "event_callback"
    event = data.event

    if event.subtype && event.subtype == "file_share"
      if @team && event.user != @team.bot["bot_user_id"]
        file = event.file

      end
    end
    #puts event.text
    if event.text
      puts "test"
	  event.text
    end

  end

  return 200'''
end

get '/oauth' do
  if params['code']
    options = {
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: params['code']
    }

	res = RestClient.post 'https://slack.com/api/oauth.access', options, content_type: :json
	save(JSON.parse(res))
    @teams.to_s 
    #save_team(JSON.parse(res))
    #erb :success
  #else
    #erb :failure
  end
end
