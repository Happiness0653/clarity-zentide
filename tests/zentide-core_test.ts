import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can register",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("zentide-core", "register-user", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensure user can log session and track streaks correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("zentide-core", "register-user", [], wallet_1.address),
      Tx.contractCall("zentide-core", "log-session", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);
    
    // Check initial streak is 1
    let user_stats = chain.callReadOnlyFn(
      "zentide-core",
      "get-user-stats",
      [types.principal(wallet_1.address)],
      wallet_1.address
    );
    
    let stats = user_stats.result.expectOk().expectSome();
    assertEquals(stats['current-streak'], types.uint(1));
  },
});

Clarinet.test({
  name: "Ensure streak validation works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("zentide-core", "register-user", [], wallet_1.address)
    ]);
    
    // Simulate unrealistic streak
    for (let i = 0; i < 366; i++) {
      chain.mineBlock([]);
    }
    
    block = chain.mineBlock([
      Tx.contractCall("zentide-core", "log-session", [], wallet_1.address)
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    let user_stats = chain.callReadOnlyFn(
      "zentide-core",
      "get-user-stats",
      [types.principal(wallet_1.address)],
      wallet_1.address
    );
    
    let stats = user_stats.result.expectOk().expectSome();
    assertEquals(stats['current-streak'], types.uint(1));
  },
});
