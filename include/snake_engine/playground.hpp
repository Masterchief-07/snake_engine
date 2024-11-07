#pragma once
#include "raylib.h"
#include <utility>
#include <snake_engine/snake.hpp>

namespace se{

class PlayGround{
    public:
    enum Collision{
        NONE,
        FOOD=0,
        UP_BORDER,
        DOWN_BORDER,
        LEFT_BORDER,
        RIGHT_BORDER,
    };
    using Pos = std::pair<int, int>;

    PlayGround(int width, int height);
    ~PlayGround();

    PlayGround& setFood(const Pos& food);
    PlayGround& setWindow(const Pos& window);

    inline const Pos& getFood() const {return this->m_food;}
    inline const Pos& getWindow() const {return this->m_window;}

    void setFoodRandom();
    Collision checkCollision(const Snake& snake);
    private:
    Pos m_window, m_food;


};

}
