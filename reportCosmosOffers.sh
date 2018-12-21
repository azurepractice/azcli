#!/usr/local/bin/bash

finalResult="AccountName AccountRG DBName CollectionName SpecifiedThroughput\n"

# get all of the account names (need to set the sub first!!! TODO)
cosmosAccounts=$(az cosmosdb list --query '[].{name:name, resourceGroup:resourceGroup}' --output tsv)
#printf '%s\n' "$cosmosAccounts" |
while read -r accountName accountRG
do
        echo "Name: $accountName"
        echo "RG: $accountRG"
        accountDBs=$(az cosmosdb database list -n $accountName -g $accountRG --query '[].{id:id}' --output tsv)
        #printf '%s\n' "$accountDBs" |
        while read -r dbName
        do
                if [ -z "$dbName" ]
                then
                        $a
                else
                        echo "--DB Name: $dbName"
                        collectionList=$(az cosmosdb collection list -n $accountName -g $accountRG -d $dbName --query '[].{id:id}' --output tsv)
                        #printf '%s\n' "$collectionList" |
                        while read -r collectionName
                        do
                                echo "----Collection: $collectionName"
                                throughput=$(az cosmosdb collection show -n $accountName -g $accountRG -d $dbName -c $collectionName --query '{offerThroughput:offer.content.offerThroughput, userSpecifiedThroughput:offer.content.userSpecifiedThroughput}' --output tsv)
                                #printf '%s\n' "$throughput" |
                                while read -r offerThroughput specifiedThroughput
                                do
                                        echo "------Offer: $offerThroughput"
                                        echo "------Specified: $specifiedThroughput"
                                        finalResult+="$accountName $accountRG $dbName $collectionName $specifiedThroughput\n"
                                done <<< $throughput
                                echo ""
                         done <<< $collectionList
                fi
        done <<< $accountDBs
        echo ""
done <<< $cosmosAccounts
#echo "*************$finalResult******************"
echo ""
echo ""
echo -e $finalResult | column -t |sort -k5 -n

