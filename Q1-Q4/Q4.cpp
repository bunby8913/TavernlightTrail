// Q4 - Assume all method calls work fine. Fix the memory leak issue in below
// method
// I would like to present 2 approaches, using raw poitner(straightforward and
// early C++ version compatible) and using smart pointer (recommended)
//
// The first approach, continue to use raw pointer and manually to release
// resources. This will works but is not a fool-proof solution as any of the
// functions call
void Game::addItemToPlayer(const std::string &recipient, uint16_t itemId) {
  Player *player = g_game.getPlayerByName(recipient);
  if (!player) {
    // Memory leak here! If the player reference cannot be
    // retrieved by name, a new player object is created and assigned to the
    // `player` pointer. However, this allocated memory to the player object
    // does not get released at the end of the function, causing a memory leak
    player = new Player(nullptr);
    if (!IOLoginData::loadPlayerByName(player, recipient)) {
      delete player; // If the player cannot be loaded by name, before exiting
                     // the function, memory associated with the player object
                     // should be released to prevent memory leak
      return;
    }
  }

  Item *item = Item::CreateItem(itemId);
  if (!item) {
    delete player; // Again, make sure that the player object is deleted before
                   // exiting the function
    // We don't need to delete item if it fails to construct
    return;
  }

  // I use try + catch block here in case any of those functions throws an
  // exception and exit the function before reaching the end of the function,
  // resulting in memory leak
  // This assumes that both `internalAddItem` and
  // `ifOffline` does not not manage the pointer passed in
  try {
    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER,
                           FLAG_NOLIMIT);

    if (player->isOffline()) {
      IOLoginData::savePlayer(player);
    }
  } catch (const std::exception &) {
    delete item;
    delete player;
    // Exit the function to avoid releasing the resources twice, which could
    // also cause issues
    return;
  }
  delete item; // Delete and release resources to avoid memory leak
  delete player;
}

// The second approach, if we are C++ 11 and beyond smart pointer is a much
// better choice to avoid memory leak, we will use a std::unique_ptr here

void Game::addItemToPlayer(const std::string &recipient, uint16_t itemId) {
  // Using unique pointer so that once the execution exits the function, the
  // resources allocated will get cleaned up automatically
  std::unique_ptr<Player> player(g_game.getPlayerByName(recipient));
  if (!player) {
    player = std::make_unique<Player>(nullptr);
    // Using the `get()` function to retrieve the object managed by the unique
    // pointer
    if (!IOLoginData::loadPlayerByName(player.get(), recipient)) {
      return;
    }
    // Same with the item, given the function sounds like its creating a new
    // item object dynamically
    std::unique_ptr<Item> item(Item::CreateItem(itemId));
    if (!item) {
      return;
    }

    g_game.internalAddItem(player->getInbox(), item.get(), INDEX_WHEREEVER,
                           FLAT_NOLIMIT);
  }
  if (player->isOffline()) {
    IOLoginData::savePlayer(player.get());
  }
  // Unique pointer will be automatically cleaned up after the program exit the
  // function
}
