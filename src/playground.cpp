#include <snake_engine/playground.hpp>
#include <raylib.h>
using namespace se;

PlayGround::PlayGround(int width, int height):m_window{width, height}, m_food{width/2, height/2}{

}

PlayGround::~PlayGround(){}

PlayGround& PlayGround::setFood(const Pos& food){
    this->m_food = food;
    return *this;
}

PlayGround& PlayGround::setWindow(const Pos& window){
    this->m_window = window;
    return *this;
}

void PlayGround::setFoodRandom(){
    Snake::Pos n_pos{
        GetRandomValue(0, this->m_window.first-1),
        GetRandomValue(0, this->m_window.second-1)
    };
    this->m_food = n_pos;
}

PlayGround::Collision PlayGround::checkCollision(const Snake& snake){
    const auto& shead = snake.getHead();
    if ( shead == this->m_food)
        return PlayGround::Collision::FOOD;
    else if (shead.first < 0)
        return PlayGround::Collision::LEFT_BORDER;
    else if (shead.first >= this->m_window.first)
        return PlayGround::Collision::RIGHT_BORDER;
    else if (shead.second < 0)
        return PlayGround::Collision::UP_BORDER;
    else if (shead.second >= this->m_window.second)
        return PlayGround::Collision::DOWN_BORDER;
    
    return PlayGround::Collision::NONE;
}

void PlayGround::draw(){

}
