/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type {
  ERC721A,
  ERC721AInterface,
} from "../../../../erc721a/contracts/ERC721A.sol/ERC721A";

const _abi = [
  {
    inputs: [
      {
        internalType: "string",
        name: "name_",
        type: "string",
      },
      {
        internalType: "string",
        name: "symbol_",
        type: "string",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "ApprovalCallerNotOwnerNorApproved",
    type: "error",
  },
  {
    inputs: [],
    name: "ApprovalQueryForNonexistentToken",
    type: "error",
  },
  {
    inputs: [],
    name: "ApprovalToCurrentOwner",
    type: "error",
  },
  {
    inputs: [],
    name: "ApproveToCaller",
    type: "error",
  },
  {
    inputs: [],
    name: "BalanceQueryForZeroAddress",
    type: "error",
  },
  {
    inputs: [],
    name: "MintToZeroAddress",
    type: "error",
  },
  {
    inputs: [],
    name: "MintZeroQuantity",
    type: "error",
  },
  {
    inputs: [],
    name: "OwnerQueryForNonexistentToken",
    type: "error",
  },
  {
    inputs: [],
    name: "TransferCallerNotOwnerNorApproved",
    type: "error",
  },
  {
    inputs: [],
    name: "TransferFromIncorrectOwner",
    type: "error",
  },
  {
    inputs: [],
    name: "TransferToNonERC721ReceiverImplementer",
    type: "error",
  },
  {
    inputs: [],
    name: "TransferToZeroAddress",
    type: "error",
  },
  {
    inputs: [],
    name: "URIQueryForNonexistentToken",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "approved",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "approved",
        type: "bool",
      },
    ],
    name: "ApprovalForAll",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "getApproved",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "operator",
        type: "address",
      },
    ],
    name: "isApprovedForAll",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "ownerOf",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "safeTransferFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_data",
        type: "bytes",
      },
    ],
    name: "safeTransferFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        internalType: "bool",
        name: "approved",
        type: "bool",
      },
    ],
    name: "setApprovalForAll",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes4",
        name: "interfaceId",
        type: "bytes4",
      },
    ],
    name: "supportsInterface",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "tokenURI",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x60806040523480156200001157600080fd5b5060405162001f2e38038062001f2e83398181016040528101906200003791906200021b565b8160029081620000489190620004eb565b5080600390816200005a9190620004eb565b506200006b6200007960201b60201c565b6000819055505050620005d2565b600090565b6000604051905090565b600080fd5b600080fd5b600080fd5b600080fd5b6000601f19601f8301169050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b620000e7826200009c565b810181811067ffffffffffffffff82111715620001095762000108620000ad565b5b80604052505050565b60006200011e6200007e565b90506200012c8282620000dc565b919050565b600067ffffffffffffffff8211156200014f576200014e620000ad565b5b6200015a826200009c565b9050602081019050919050565b60005b83811015620001875780820151818401526020810190506200016a565b8381111562000197576000848401525b50505050565b6000620001b4620001ae8462000131565b62000112565b905082815260208101848484011115620001d357620001d262000097565b5b620001e084828562000167565b509392505050565b600082601f8301126200020057620001ff62000092565b5b8151620002128482602086016200019d565b91505092915050565b6000806040838503121562000235576200023462000088565b5b600083015167ffffffffffffffff8111156200025657620002556200008d565b5b6200026485828601620001e8565b925050602083015167ffffffffffffffff8111156200028857620002876200008d565b5b6200029685828601620001e8565b9150509250929050565b600081519050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b60006002820490506001821680620002f357607f821691505b602082108103620003095762000308620002ab565b5b50919050565b60008190508160005260206000209050919050565b60006020601f8301049050919050565b600082821b905092915050565b600060088302620003737fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8262000334565b6200037f868362000334565b95508019841693508086168417925050509392505050565b6000819050919050565b6000819050919050565b6000620003cc620003c6620003c08462000397565b620003a1565b62000397565b9050919050565b6000819050919050565b620003e883620003ab565b62000400620003f782620003d3565b84845462000341565b825550505050565b600090565b6200041762000408565b62000424818484620003dd565b505050565b5b818110156200044c57620004406000826200040d565b6001810190506200042a565b5050565b601f8211156200049b5762000465816200030f565b620004708462000324565b8101602085101562000480578190505b620004986200048f8562000324565b83018262000429565b50505b505050565b600082821c905092915050565b6000620004c060001984600802620004a0565b1980831691505092915050565b6000620004db8383620004ad565b9150826002028217905092915050565b620004f682620002a0565b67ffffffffffffffff811115620005125762000511620000ad565b5b6200051e8254620002da565b6200052b82828562000450565b600060209050601f8311600181146200056357600084156200054e578287015190505b6200055a8582620004cd565b865550620005ca565b601f19841662000573866200030f565b60005b828110156200059d5784890151825560018201915060208501945060208101905062000576565b86831015620005bd5784890151620005b9601f891682620004ad565b8355505b6001600288020188555050505b505050505050565b61194c80620005e26000396000f3fe608060405234801561001057600080fd5b50600436106100ea5760003560e01c80636352211e1161008c578063a22cb46511610066578063a22cb4651461025d578063b88d4fde14610279578063c87b56dd14610295578063e985e9c5146102c5576100ea565b80636352211e146101df57806370a082311461020f57806395d89b411461023f576100ea565b8063095ea7b3116100c8578063095ea7b31461016d57806318160ddd1461018957806323b872dd146101a757806342842e0e146101c3576100ea565b806301ffc9a7146100ef57806306fdde031461011f578063081812fc1461013d575b600080fd5b6101096004803603810190610104919061121c565b6102f5565b6040516101169190611264565b60405180910390f35b610127610387565b6040516101349190611318565b60405180910390f35b61015760048036038101906101529190611370565b610419565b60405161016491906113de565b60405180910390f35b61018760048036038101906101829190611425565b610495565b005b61019161063b565b60405161019e9190611474565b60405180910390f35b6101c160048036038101906101bc919061148f565b610652565b005b6101dd60048036038101906101d8919061148f565b610662565b005b6101f960048036038101906101f49190611370565b610682565b60405161020691906113de565b60405180910390f35b610229600480360381019061022491906114e2565b610694565b6040516102369190611474565b60405180910390f35b61024761074c565b6040516102549190611318565b60405180910390f35b6102776004803603810190610272919061153b565b6107de565b005b610293600480360381019061028e91906116b0565b610955565b005b6102af60048036038101906102aa9190611370565b6109c8565b6040516102bc9190611318565b60405180910390f35b6102df60048036038101906102da9190611733565b610a66565b6040516102ec9190611264565b60405180910390f35b60006301ffc9a760e01b827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916148061035057506380ac58cd60e01b827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916145b806103805750635b5e139f60e01b827bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916145b9050919050565b606060028054610396906117a2565b80601f01602080910402602001604051908101604052809291908181526020018280546103c2906117a2565b801561040f5780601f106103e45761010080835404028352916020019161040f565b820191906000526020600020905b8154815290600101906020018083116103f257829003601f168201915b5050505050905090565b600061042482610afa565b61045a576040517fcf4700e400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6006600083815260200190815260200160002060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b60006104a082610b59565b90508073ffffffffffffffffffffffffffffffffffffffff168373ffffffffffffffffffffffffffffffffffffffff1603610507576040517f943f7b8c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8073ffffffffffffffffffffffffffffffffffffffff16610526610c25565b73ffffffffffffffffffffffffffffffffffffffff1614610589576105528161054d610c25565b610a66565b610588576040517fcfb3b94200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5b826006600084815260200190815260200160002060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550818373ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a4505050565b6000610645610c2d565b6001546000540303905090565b61065d838383610c32565b505050565b61067d83838360405180602001604052806000815250610955565b505050565b600061068d82610b59565b9050919050565b60008073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16036106fb576040517f8f4eb60400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b67ffffffffffffffff600560008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054169050919050565b60606003805461075b906117a2565b80601f0160208091040260200160405190810160405280929190818152602001828054610787906117a2565b80156107d45780601f106107a9576101008083540402835291602001916107d4565b820191906000526020600020905b8154815290600101906020018083116107b757829003601f168201915b5050505050905090565b6107e6610c25565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff160361084a576040517fb06307db00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8060076000610857610c25565b73ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055508173ffffffffffffffffffffffffffffffffffffffff16610904610c25565b73ffffffffffffffffffffffffffffffffffffffff167f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31836040516109499190611264565b60405180910390a35050565b610960848484610c32565b60008373ffffffffffffffffffffffffffffffffffffffff163b146109c25761098b84848484610fd9565b6109c1576040517fd1a57ed600000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5b50505050565b60606109d382610afa565b610a09576040517fa14c4b5000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6000610a13611129565b90506000815103610a335760405180602001604052806000815250610a5e565b80610a3d84611140565b604051602001610a4e92919061180f565b6040516020818303038152906040525b915050919050565b6000600760008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16905092915050565b600081610b05610c2d565b11158015610b14575060005482105b8015610b52575060007c0100000000000000000000000000000000000000000000000000000000600460008581526020019081526020016000205416145b9050919050565b60008082905080610b68610c2d565b11610bee57600054811015610bed5760006004600083815260200190815260200160002054905060007c0100000000000000000000000000000000000000000000000000000000821603610beb575b60008103610be1576004600083600190039350838152602001908152602001600020549050610bb7565b8092505050610c20565b505b5b6040517fdf2d9b4200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b919050565b600033905090565b600090565b6000610c3d82610b59565b90508373ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614610ca4576040517fa114810000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60008473ffffffffffffffffffffffffffffffffffffffff16610cc5610c25565b73ffffffffffffffffffffffffffffffffffffffff161480610cf45750610cf385610cee610c25565b610a66565b5b80610d395750610d02610c25565b73ffffffffffffffffffffffffffffffffffffffff16610d2184610419565b73ffffffffffffffffffffffffffffffffffffffff16145b905080610d72576040517f59c896be00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff1603610dd8576040517fea553b3400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b610de5858585600161119a565b6006600084815260200190815260200160002060006101000a81549073ffffffffffffffffffffffffffffffffffffffff0219169055600560008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600081546001900391905081905550600560008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008154600101919050819055507c020000000000000000000000000000000000000000000000000000000060a042901b610ee2866111a0565b1717600460008581526020019081526020016000208190555060007c0200000000000000000000000000000000000000000000000000000000831603610f6a5760006001840190506000600460008381526020019081526020016000205403610f68576000548114610f67578260046000838152602001908152602001600020819055505b5b505b828473ffffffffffffffffffffffffffffffffffffffff168673ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4610fd285858560016111aa565b5050505050565b60008373ffffffffffffffffffffffffffffffffffffffff1663150b7a02610fff610c25565b8786866040518563ffffffff1660e01b81526004016110219493929190611888565b6020604051808303816000875af192505050801561105d57506040513d601f19601f8201168201806040525081019061105a91906118e9565b60015b6110d6573d806000811461108d576040519150601f19603f3d011682016040523d82523d6000602084013e611092565b606091505b5060008151036110ce576040517fd1a57ed600000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b805181602001fd5b63150b7a0260e01b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916817bffffffffffffffffffffffffffffffffffffffffffffffffffffffff191614915050949350505050565b606060405180602001604052806000815250905090565b60606080604051019050806040528082600183039250600a81066030018353600a810490505b801561118657600183039250600a81066030018353600a81049050611166565b508181036020830392508083525050919050565b50505050565b6000819050919050565b50505050565b6000604051905090565b600080fd5b600080fd5b60007fffffffff0000000000000000000000000000000000000000000000000000000082169050919050565b6111f9816111c4565b811461120457600080fd5b50565b600081359050611216816111f0565b92915050565b600060208284031215611232576112316111ba565b5b600061124084828501611207565b91505092915050565b60008115159050919050565b61125e81611249565b82525050565b60006020820190506112796000830184611255565b92915050565b600081519050919050565b600082825260208201905092915050565b60005b838110156112b957808201518184015260208101905061129e565b838111156112c8576000848401525b50505050565b6000601f19601f8301169050919050565b60006112ea8261127f565b6112f4818561128a565b935061130481856020860161129b565b61130d816112ce565b840191505092915050565b6000602082019050818103600083015261133281846112df565b905092915050565b6000819050919050565b61134d8161133a565b811461135857600080fd5b50565b60008135905061136a81611344565b92915050565b600060208284031215611386576113856111ba565b5b60006113948482850161135b565b91505092915050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b60006113c88261139d565b9050919050565b6113d8816113bd565b82525050565b60006020820190506113f360008301846113cf565b92915050565b611402816113bd565b811461140d57600080fd5b50565b60008135905061141f816113f9565b92915050565b6000806040838503121561143c5761143b6111ba565b5b600061144a85828601611410565b925050602061145b8582860161135b565b9150509250929050565b61146e8161133a565b82525050565b60006020820190506114896000830184611465565b92915050565b6000806000606084860312156114a8576114a76111ba565b5b60006114b686828701611410565b93505060206114c786828701611410565b92505060406114d88682870161135b565b9150509250925092565b6000602082840312156114f8576114f76111ba565b5b600061150684828501611410565b91505092915050565b61151881611249565b811461152357600080fd5b50565b6000813590506115358161150f565b92915050565b60008060408385031215611552576115516111ba565b5b600061156085828601611410565b925050602061157185828601611526565b9150509250929050565b600080fd5b600080fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6115bd826112ce565b810181811067ffffffffffffffff821117156115dc576115db611585565b5b80604052505050565b60006115ef6111b0565b90506115fb82826115b4565b919050565b600067ffffffffffffffff82111561161b5761161a611585565b5b611624826112ce565b9050602081019050919050565b82818337600083830152505050565b600061165361164e84611600565b6115e5565b90508281526020810184848401111561166f5761166e611580565b5b61167a848285611631565b509392505050565b600082601f8301126116975761169661157b565b5b81356116a7848260208601611640565b91505092915050565b600080600080608085870312156116ca576116c96111ba565b5b60006116d887828801611410565b94505060206116e987828801611410565b93505060406116fa8782880161135b565b925050606085013567ffffffffffffffff81111561171b5761171a6111bf565b5b61172787828801611682565b91505092959194509250565b6000806040838503121561174a576117496111ba565b5b600061175885828601611410565b925050602061176985828601611410565b9150509250929050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b600060028204905060018216806117ba57607f821691505b6020821081036117cd576117cc611773565b5b50919050565b600081905092915050565b60006117e98261127f565b6117f381856117d3565b935061180381856020860161129b565b80840191505092915050565b600061181b82856117de565b915061182782846117de565b91508190509392505050565b600081519050919050565b600082825260208201905092915050565b600061185a82611833565b611864818561183e565b935061187481856020860161129b565b61187d816112ce565b840191505092915050565b600060808201905061189d60008301876113cf565b6118aa60208301866113cf565b6118b76040830185611465565b81810360608301526118c9818461184f565b905095945050505050565b6000815190506118e3816111f0565b92915050565b6000602082840312156118ff576118fe6111ba565b5b600061190d848285016118d4565b9150509291505056fea264697066735822122010960a9972f5812f535e8be61dfdb5d405217e1d0245a89c07e0e7f21f7b934e64736f6c634300080f0033";

type ERC721AConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ERC721AConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ERC721A__factory extends ContractFactory {
  constructor(...args: ERC721AConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    name_: PromiseOrValue<string>,
    symbol_: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ERC721A> {
    return super.deploy(name_, symbol_, overrides || {}) as Promise<ERC721A>;
  }
  override getDeployTransaction(
    name_: PromiseOrValue<string>,
    symbol_: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(name_, symbol_, overrides || {});
  }
  override attach(address: string): ERC721A {
    return super.attach(address) as ERC721A;
  }
  override connect(signer: Signer): ERC721A__factory {
    return super.connect(signer) as ERC721A__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ERC721AInterface {
    return new utils.Interface(_abi) as ERC721AInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ERC721A {
    return new Contract(address, _abi, signerOrProvider) as ERC721A;
  }
}