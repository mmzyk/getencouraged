# getencouraged

getencouraged is a simple twitter application that looks for @replies to an account and then retweets then from the account.  It also has a front end to display @replies sent to an account.


# Set up

Rename the config.app.sample file to config.app and fill in the needed parameters.

username: the username of the account that should retweet the @replies sent to it
password: the password for the account
testing: if analytics code is placed in index.erb, this option can be used to turn it on or off for testing purposes
number_to_tweet: this is the number of @replies that should be retweeted each time the script is run.  The default is -1, which retweets all @replies.

Once the config.app is in place, use a cron job to run the repost script at a set interval and on that interval the @replies will be retweeted.

The front end can be deployed and run with the Sinatra framework.  To do that, ensure you have Sinatra loaded and run getencouraged.rb.  You will likely want to modify the look and feel of the front end to fit your needs.


# Dependencies

The twitter gem

For testing:

mocha

rcov


For the front end:

Sinatra


# License

Creative Commons Attribution 3.0
See LICENSE.txt for further details


# Extraneous

Have fun!