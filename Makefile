-include .env

build:; forge build

deploy-op_sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(OP_SEPOLIA_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(OP_ETHERSCAN_API_KEY) -vvvv 

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_PRC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv 



