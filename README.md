# hackathon_2017
hackathon 2017

#how to run?


Once you know you have the correct Ruby version, install Bundler by running gem install bundler

After installing Bundler, you can use Bundler to install the required gems from our Gemfile by running bundle install

Export the required creds to your environment var (you can get the values from api.slack):

export SLACK_CLIENT_ID="232410039537.233158678933"

export SLACK_CLIENT_SECRET="put your client secret here"

export SLACK_VERIFICATION_TOKEN="put your verification token here"

Finally run:

Ruby myapp.rb
