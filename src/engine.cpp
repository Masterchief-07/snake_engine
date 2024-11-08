#include<snake_engine/engine.hpp>
#include<raylib.h>
//#include<iostream>

using namespace se;

Engine::Engine():Engine{"window", 400, 800}{

}

Engine::Engine(std::string title, int width, int height)
:m_title{title}, m_width{width}, m_height{height}, m_fps{60}, m_snake{}, m_playground{width, height}{
   InitWindow(
           this->m_width,
           this->m_height,
           this->m_title.c_str()
       );
}

Engine::~Engine(){
    CloseWindow();
}

Engine& Engine::setSnake(Snake&& snake){
    this->m_snake = snake;
    return *this;
}

Engine& Engine::setPlayGround(PlayGround&& playground){
    this->m_playground = playground;
    return *this;
}

Engine& Engine::setWindowSize(int width, int height){
    this->m_width = width;
    this->m_height = height;
    return *this;
}

Engine& Engine::setFPS(int fps){
    this->m_fps = fps;
    return *this;
}

Engine& Engine::setWindowTitle(std::string title){
    this->m_title = title;
    return *this;
}

bool Engine::running(){
    return WindowShouldClose();
}

void Engine::step(){
    this->m_snake.move(Snake::Direction::LEFT);
    this->m_playground.checkCollision(this->m_snake);
}

bool Engine::running(){
   this->m_playground.draw(); 
   this->m_snake.draw();
}
