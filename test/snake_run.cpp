#include <iostream>
#include <snake_engine/engine.hpp>

int main(){
    auto sn = se::Snake{};
    auto pg = se::PlayGround{800, 400};
    auto engine = se::Engine{"snake", 800, 400};

    engine
        .setSnake(se::Snake{})
        .setPlayGround(se::PlayGround{800, 400});

    return 0;
}
