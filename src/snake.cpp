#include <snake_engine/snake.hpp>

using namespace se;

Snake::Snake():Snake(Snake::Direction::LEFT, {0, 0}){

}

Snake::Snake(Snake::Direction dir, Snake::Pos start_pos):m_direction{dir}, m_body{start_pos}{

}

Snake::~Snake(){

}

void Snake::move(Snake::Direction dir, int speed){
    auto& dir_v = this->DIRECTIONS.at(dir);

    auto m_1 = this->m_body.front();
    for(size_t i=1; i<this->m_body.size(); i++){
        auto& secondo = this->m_body[i];
        Pos m_2{secondo};
        secondo.first = m_1.first;
        secondo.second = m_1.second;
        m_1 = m_2;
    }

    this->m_body.front().first = this->m_body.front().first + dir_v.first * speed;
    this->m_body.front().second = this->m_body.front().second + dir_v.second * speed;
}

void Snake::add_body(size_t count){
    const auto& last = this->m_body.back();
    for(size_t i=0; i < count; i++)
        this->m_body.push_back(
            Pos{last.first, last.second}
        );
}


