import * as fs from "fs";
import { File, NFTStorage } from "nft.storage";
import * as path from "path";

require('dotenv').config();

const apiKey = process.env.NFT_STORAGE_API_KEY;
if (!apiKey) {
    throw "Set NFT.storage API key first!"
}
const client = new NFTStorage({ token: apiKey })

const store = async () => {
    const metadata = await client.store({
        name: 'Pool Party Presale Exclusive',
        description: 'This NFT is awarded to every contributor who bought full amount of 950k $PP tokens in the Pool Party presale.',
        image: new File([await fs.promises.readFile(path.resolve('./scripts/files/pp_3d_square.mp4'))], 'pp_3d_square.mp4', { type: 'video/mp4' })
    })
    console.log(metadata.url)
}

store();