TOP_DIR=$(cd $(dirname "$0") && pwd)
DATA_DIR=$TOP_DIR
REDDIT_USERS=$DATA_DIR/users
USER_PROFILE_DIR=$DATA_DIR/userprofiles
USER_LINK_DIR=$DATA_DIR/userlinks
ALL_LINKS=$DATA_DIR/all.links
ALL_SUBREDDITS=$DATA_DIR/all.subreddits

cd $DATA_DIR

touch $ALL_LINKS

curl https://www.reddit.com | pup a | grep user | grep may-blank | sed -e 's/.*user\///g' -e 's/".*//g' >> $REDDIT_USERS

mkdir -p $USER_PROFILE_DIR $USER_LINK_DIR

while true
do 
  for user in $(cat $REDDIT_USERS) 
  do
    USER_PAGE=$USER_PROFILE_DIR/$user
    USER_LINKS_PAGE=$USER_LINK_DIR/${user}.links
    
    if [ -f "$USER_PAGE" ] 
    then 
      echo "found user data already for user $user"
      continue
    fi

    echo "didnt find user $user"
    sleep 5

    curl https://www.reddit.com/user/$user > $USER_PAGE
    
    #find links
    cat $USER_PAGE | pup 'div#siteTable div p.parent a.title' | grep '<a' | sed -e 's/.*href="//g' -e 's/".*//g' | sort -u > $USER_LINKS_PAGE
    
    cat $USER_PAGE | pup a | grep '/user/' | grep -v '?count=' | sed -e 's/.*\/user\///g' -e 's/\("\|\?\|\/\).*//g' | sort -u >> $REDDIT_USERS
    
    cat $USER_LINKS_PAGE >> $ALL_LINKS
    sort -u -o $ALL_LINKS < $ALL_LINKS 
    sort -u -o $REDDIT_USERS < $REDDIT_USERS
    grep '/r/' < $ALL_LINKS | sed -e 's/^\/r\///g' -e 's/\/.*//g' -e 's/.*/\/r\/&/g' | sort -u >> $ALL_SUBREDDITS
    sort -u -o $ALL_SUBREDDITS < $ALL_SUBREDDITS
  done
done
