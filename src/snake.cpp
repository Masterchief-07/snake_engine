#include <snake_engine/snake.hpp>

using namespace se;

Snake::Snake():Snake(Snake::Direction::LEFT, {0, 0}){

}

Snake::Snake(Snake::Direction dir, Snake::Pos start_pos):m_direction{dir}, m_body{start_pos}{

}

Snake::~Snake(){

}

void Snake::move(Snake::Direction dir, int speed=1){
    auto& dir_v = this->M_DIRECTIONS.at(dir);

    auto m_1 = this->m_body.front();
    for(int i=1; i<this->m_body.size(); i++){
        auto& secondo = this->m_body[i];
        Pos m_2{secondo};
        secondo.first = m_1.first;
        secondo.second = m_1.second;
        m_1 = m2;
    }

    this->m_body.front().first = this->m_body.front().first + dir_v.first * speed;
    this->m_body.front().second = this->m_body.second().first + dir_v.second * speed;
}

void add_body(int count=1){
    const auto& last = this->m_body.back();
    this->m_body.push_back(
        pos{last.first, last.second}
    );
}


