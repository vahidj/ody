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
	  textObj = "Please enter a url or paste an image!!"
	  when "event_callback"
		event = data.event
		if event.subtype && event.subtype == "file_share"
          case event.file.name
            when "desktop.jpeg"
				textObj = "Here is what I found:"
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
			  textObj = "Here is what I found:"
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
			  textObj = "Here is what I found:"
			  attachments = [
        {			
            "title": "Graco 4Ever All-in-1 Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Graco-4Ever-All-in-1-Convertible-Car-Seat-Choose-Your-Pattern/46335604",
			      "image_url":"https://i5.walmartimages.com/asr/b27da759-3f31-4727-a22f-3d7bc1c41a07_1.02cf3c75fc81a513eed09a662e59266e.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D46335604%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Graco Contender 65 Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Graco-Contender-65-Convertible-Car-Seat-Choose-Your-Pattern/33396182",
			      "image_url":"https://i5.walmartimages.com/asr/328b980a-9762-422a-8f8d-53bf171b3ff5_1.b6eff89073debf58491355b572ef5936.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D33396182%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Diono Radian RXT Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Diono-Radian-RXT-Convertible-Car-Seat-Black-Cobalt/50878012",
			      "image_url":"https://i5.walmartimages.com/asr/0303efbc-d205-4c51-bd39-139af9e831f6_1.939d16a6711f79943f3b21bd347d45d3.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D50878012%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "Britax Marathon ClickTight Convertible Car Seat",
			      "title_link": "https://www.walmart.com/ip/Britax-Marathon-ClickTight-Convertible-Car-Seat-Vue/55425979",
			      "image_url":"https://i5.walmartimages.com/asr/61a8921a-b7a9-4401-8492-30a460bae83d_1.b8efebb059f3922398599d3919743129.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D55425979%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"}        
    ].to_json

            when "<http://www.parents.com/fun/entertainment/books/best-childrens-books-of-the-year/>"
			  textObj = "Here is what I found:"
              attachments = [
        {			
            "title": "Big Fish Little Fish",
			      "title_link": "https://www.walmart.com/ip/Big-Fish-Little-Fish/49207133",
			      "image_url":"http://images.parents.mdpcdn.com/sites/parents.com/files/styles/width_360/public/102787324.jpg"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D49207133%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "TouchThinkLearn: ABC",
			      "title_link": "https://www.walmart.com/ip/ABC/51797530",
			      "image_url":"https://www.walmart.com/ip/Graco-Contender-65-Convertible-Car-Seat-Choose-Your-Pattern/33396182"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D51797530%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "GOODNIGHT EVERYONE",
			      "title_link": "https://www.walmart.com/ip/GOODNIGHT-EVERYONE/912129766",
			      "image_url":"https://i5.walmartimages.com/asr/10b7cf0a-ebd6-4444-a030-8b93398ac4a2_1.5a608ea2e6bdacc29443ef5b278c2a53.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D912129766%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"},
        {			
            "title": "The Cookie Fiasco",
			      "title_link": "https://www.walmart.com/ip/The-Cookie-Fiasco/52609219",
			      "image_url":"https://i5.walmartimages.com/asr/c7a3da62-aefe-4176-a6eb-026f93d4005b_1.d9bdfc55775f3018e684afc58e330704.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
        }, 
        {"title":"ADD TO CART", "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D52609219%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"}
    ].to_json
            when "<https://ezinearticles.com/?cat=Home-Improvement:Furniture>>"
			  textObj = "Here is what I found:"
              attachments = [
                {
                 "title": "Right2Home Upholstered Low Profile Bed - Queen",
                 "title_link": "https://www.walmart.com/ip/Right2Home-Upholstered-Low-Profile-Bed-Queen/39449500",
                 "image_url": "https://i5.walmartimages.com/asr/adef3e1b-1d88-46c0-b52d-19b1b9930e5d_1.87c79c4d99a47b3c678ba909bbf8663d.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D39449500%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Best Choice Products Patio Umbrella",
                 "title_link": "https://www.walmart.com/ip/Best-Choice-Products-Patio-Umbrella-Offset-10-Hanging-Umbrella-Outdoor-Market-Umbrella-New-Multiple-Colors/166312054",
                 "image_url": "https://i5.walmartimages.com/asr/f66ff1dc-6c57-4a58-884d-61dfa2ff1908_1.8020b606d6e937b11db20fe303c766e1.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D166312054%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Mayline Napoli Curved End Conference Table",
                 "title_link": "https://www.walmart.com/ip/Mayline-Napoli-Curved-End-Conference-Table-in-Golden-Cherry-12/41688481",
                 "image_url": "https://i5.walmartimages.com/asr/b08e0412-9d9c-49bd-9c1e-ca185923e1fc_1.f5f94b5776ea0d8955cfe17ae8b24db4.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D41688481%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Lifestyle Solutions Zola Sofa",
                 "title_link": "https://www.walmart.com/ip/Lifestyle-Solutions-Zola-Sofa-Dark-Grey/55322805",
                 "image_url": "https://i5.walmartimages.com/asr/ceda4c9d-19f2-4f35-989b-bd3a2e938834_1.6c1104c6ee25ee89ab88ee5894f53b0a.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D55322805%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                }
                ].to_json

            when "<https://www.pinterest.com/pin/433823376584880457/>"
			  textObj = "Here is what I found:"
              attachments = [
                {
                 "title": "Bread flour",
                 "title_link": "https://www.walmart.com/ip/Pilsbury-Bread-Flour-5-lbs/10308169",
                 "image_url": "https://i5.walmartimages.com/asr/f5e5a6cf-56de-4bbc-98a2-e90e5a05d91d_1.7d974e54071cea00fd76ccc84675d44e.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                }, 
                {
                 "title":"ADD TO CART", 
                 "title_link":"http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapihttp://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10308169%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Granulated sugar",
                 "title_link": "https://www.walmart.com/ip/Domino-Premium-Sugar-Cane-Granulated-Sugar-4-lb-Bag/19500189",
                 "image_url": "https://i5.walmartimages.com/asr/1349d0b4-bfcd-454c-8b9a-e9e3702e16c4_1.fec4ebcb6bf5d33d57118aba6c76cbad.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title":"ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D19500189%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Butter, unsalted",
                 "title_link": "https://www.walmart.com/ip/Isigny-Unsalted-Butter-in-Basket/104722419",
                 "image_url": "https://i5.walmartimages.com/asr/2856ac2e-df40-4c09-b6fc-8eea71d65add_1.4cb4757d79546a7c64b96695d217f294.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CART",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D104722419%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                },
                {
                 "title": "Instant (quick-rise) yeast",
                 "title_link": "https://www.walmart.com/ip/Red-Star-Quick-Rise-Instant-Yeast-3-25-oz-Packets/10319305",
                 "image_url": "https://i5.walmartimages.com/asr/97f90f1f-0382-4c76-93e3-64dd25a88e1c_1.78a8db0558c09d43e9dc07ae625ad87c.jpeg?odnHeight=200&odnWidth=200&odnBg=FFFFFF"
                },
                {
                 "title": "ADD TO CADT",
                 "title_link": "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Faffil.walmart.com%2Fcart%2FaddToCart%3Fitems%3D10319305%7C1%26affp1%3Drba2WcSC_JIWqxXZi_v0-wKblIq8dKLZ3Y_MK_UN1qY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi"
                }
                ].to_json
            else
              textObj = "Please enter a url or paste an image!!"
		  end
		end
	  
      options = {
	  token: @team.bot["bot_access_token"],
	  channel: data["event"]["channel"],
	  text: textObj,
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
