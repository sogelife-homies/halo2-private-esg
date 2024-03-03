#!/bin/bash

source .env

forge script --rpc-url 	https://node.ghostnet.etherlink.com --legacy \
    --private-key $EVM_PRIVATE_KEY  script/SnarkedKPIVault.s.sol:AddKPIVaultScript \
    --broadcast --ffi  --skip-simulation  --etherscan-api-key 0x123 
    #--etherscan-api-key 0x123  --verify --verifier blockscout --verifier-url https://testnet-explorer.etherlink.com/api -vvv 
