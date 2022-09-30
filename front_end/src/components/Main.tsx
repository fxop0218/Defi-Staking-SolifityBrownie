import {useEthers} from "@usedapp/core"
import helperConfig from "../helper-config.json"
import networkMapping from "../chain-info/deployments/map.json"
import { constants } from "ethers"
import brownieConfig from "../brownie-config.json"
import { useWeb3React } from '@web3-react/core'
import { Web3Provider } from '@ethersproject/providers'

export const Main = () => {
    // Show token vlues from the wallet

    // get the address of differents values
    // Get the valance of the users walle
    

    const { chainId, account, activate, active,library } = useWeb3React<Web3Provider>()
    console.log("Chain id: " + chainId)

    const networkName = chainId ? helperConfig[chainId] : "dev"


    const dappTokenAddress = chainId ? networkMapping[String(chainId)]["DappToken"][0] : constants.AddressZero;
    const wethTokenAddress = chainId ? brownieConfig["networks"][networkName]["weth_token"] : constants.AddressZero; // get from brownie config
    const fauTokenAddress = chainId ? brownieConfig["networks"][networkName]["fau_token"] : constants.AddressZero;
    return(<div>Hi! MDFK</div>)
}