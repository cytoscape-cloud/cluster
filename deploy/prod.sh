TLD=$(git rev-parse --show-toplevel)
FILES=$(find $TLD -mindepth 2 -type f -name '*.yaml')
echo $FILES
for FILENAME in $FILES; do
  echo "Deploying $FILENAME" 
  kubectl --namespace=production apply -f $FILENAME
done
