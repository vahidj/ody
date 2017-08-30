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
            when "test1.jpeg"
              urls = "check this out:\nhttps://www.walmart.com/search/?query=laptop&typeahead=lapto"
            when "test2.jpg"
              urls = "here you go:\nhttps://www.walmart.com/search/?query=pen&cat_id=0"
          end
        else
          case event.text
            when /^hi|hello|hey.*/
              urls = "Hi! Nice to meet you. I am Ody, the walmart.com shopping assistant! You can paste an url or upload an image here. I will try my best to find the most relevant products for you from walmart.com."
            when "<http://pcmag.com/article2/0,2817,2475954,00.asp>"
			  attachments = [{"title": "Arlo Pro System","text":"https://www.walmart.com/ip/Arlo-Pro-System-Rechargeable-Wire-Free-HD-Security-Camera-with-Audio-and-Siren-VMS4130-100NAS-by-NETGEAR/55150123","image_url": "https://i5.walmartimages.com/asr/eae4eaf7-5a30-4c54-bc90-a5a76c80cdfe_1.bf351a6533ad2f36917f501ed144996a.jpeg?odnHeight=450&odnWidth=450&odnBg=FFFFFF"},
				  {"title": "Nest Cam Outdoor Security Camera","text":"https://www.walmart.com/ip/Nest-Cam-Outdoor-Security-Camera/155798632","image_url": "https://i5.walmartimages.com/asr/b199c0d9-86aa-42f1-ac3f-3637ef56efd3_1.fce069482ad72486a7e0b97dd61c81af.jpeg?odnHeight=450&odnWidth=450&odnBg=FFFFFF"},
				  {"title": "Canary Security Device All-in-One","text":"https://www.walmart.com/ip/Canary-Security-Device-All-in-One-Home-Security-Solution-White/44443683","image_url": "https://i5.walmartimages.com/asr/9117c758-b80f-466c-bd80-7477a12e9ec7_1.bff26206edca124c038793c4ff62f9e3.jpeg?odnHeight=450&odnWidth=450&odnBg=FFFFFF"},
				  {"title": "Nest Labs Nest Cam Wireless Video Camera","text":"https://www.walmart.com/ip/Nest-Labs-Nest-Cam-Wireless-Video-Camera/45806610","image_url": "https://i5.walmartimages.com/asr/7f8f832a-ea2e-4cb0-85b1-189ececd26a1_1.9578978131fdc2df2c892a8861016802.jpeg?odnHeight=450&odnWidth=450&odnBg=FFFFFF"}].to_json

            when "<http://wm6.walmart.com/recipe/Parmesan-Butternut-Squash-Gratin>"
              urls = "check what I've found\nhttps://www.walmart.com/ip/Ferry-Morse-Fm-Foil-Squash-Dark-Green-Zucchini/179445110\nhttps://www.walmart.com/ip/LAND-O-LAKES-Margarine-1-lb-Box/10291054\nhttps://grocery.walmart.com/product/3000100169\nhttps://www.walmart.com/ip/Progresso-Plain-Panko-Crispy-Bread-Crumbs-8-oz/10320633\nhttps://www.walmart.com/ip/Progresso-Plain-Panko-Crispy-Bread-Crumbs-8-oz/10320633"
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
	  text: urls,
	  unfurl_links: true,
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
