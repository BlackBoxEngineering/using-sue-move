const tx = new TransactionBlock()
const arg0 = tx.pure(systemStakeId)
const arg1 = tx.splitCoins(tx.gas, [tx.pure(1000000000)])
const arg2 = tx.pure(validatorAddress)
tx.setSender(address)
tx.setGasBudget(30000000)

tx.moveCall({
  target: `${stakePackageId}::sui_system::request_add_stake`,
  arguments: [arg0, arg1, arg2]
})


const res = await provider.dryRunTransactionBlock({ transactionBlock: await tx.build({ provider }) })
const { computationCost, storageCost, storageRebate } = res.effects.gasUsed
const gasFee = (Number(computationCost) + Number(storageCost)) * MIST_TO_SUI