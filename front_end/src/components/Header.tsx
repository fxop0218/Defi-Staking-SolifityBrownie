import {useEthers} from "@usedapp/core"
import {Button, makeStyles} from "@material-ui/core"

const useStyles = makeStyles((theme) => ({
    container: {
        padding: theme.spacing(4),
        display: "flex",
        justifyContent: "flex-end",
        gap: theme.spacing(1)
    },
}))

export const Header = () => {
    const classes = useStyles(); 
    const {activateBrowserWallet, account, deactivate, chainId} = useEthers();
    console.log("Chain Id: " + chainId)
    const isConnected = account !== undefined
    
    return(
        <div className={classes.container}>
            <div>
                {isConnected ? (
                    <button color="primary" onClick={deactivate}>Disconect</button>
                ) : (
                    <button color="primary" onClick={() => activateBrowserWallet()}>Connect</button>)}
            </div>
        {account && <p>Account: {account}</p>}
      </div>
    )
}