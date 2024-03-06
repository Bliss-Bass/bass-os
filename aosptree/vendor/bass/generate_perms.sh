#!/bin/bash
# Generate AOSP Premisisons.xml from folder of .apk files

# Change these if using outside this project
APK_FOLDER="bin"
PERMS_LOCATION="permissions"
PERMS_FILENAME="foss-permissions.xml"

# NO MORE EDITING BELOW HERE
PARSED_PERMS_PATH="$PERMS_LOCATION/$PERMS_FILENAME"
FILES="$APK_FOLDER/*.apk"

addPerms() {
perms_list=""
cat >> $PARSED_PERMS_PATH <<EOF
	<privapp-permissions package="$2">
EOF
for i in "$@" ; do
	perms_list+="$i "
done
echo ""
#~ echo -e "Prems List: $perms_list"
#~ echo ""
for i in $perms_list ; do
if [ "$i" == "uses-permission:" ]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"package:"* ]]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"name="* ]]; then
temp_str=$(echo "$i" | sed -e "s/'/\"/g")
cat >> $PARSED_PERMS_PATH <<EOF
		<permission $temp_str/>
EOF
fi
done
cat >> $PARSED_PERMS_PATH <<EOF
    </privapp-permissions>

EOF
}

echo -e "${LT_BLUE}# Generating Permissions XML ${NC}"
rm -Rf $PARSED_PERMS_PATH
mkdir -p permissions
cat > $PARSED_PERMS_PATH <<EOF
<permissions>

EOF

for f in $FILES
do
  echo -e ""
  echo "Processing $f file..."
  cmd_list=""
  argumentqa=$(aapt d permissions "$f")
  echo ""
  echo -e "Permissions for $argumentqa"
  echo ""
  for line in $argumentqa; do 
    read -a array <<< $line
    echo ${array[index]}  
    cmd_list+="${array[index]} "
  done
  #~ echo -e "CMD_LIST: $cmd_list"
  addPerms $cmd_list
done

cat >> $PARSED_PERMS_PATH <<EOF
</permissions>

EOF

echo ""
echo -e "All Set, permissions xml generated"
