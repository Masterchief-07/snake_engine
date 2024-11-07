#pragma once
#include <string>
#include "raylib.h"
#include <snake_engine/playground.hpp>
#include <snake_engine/snake.hpp>

namespace se{

class Engine{
    
    public:
    Engine();
    Engine(std::string title, int width, int height);
    ~Engine();

    Engine& setWindowSize(int width, int height);
    Engine& setFPS(int fps);
    Engine& setWindowTitle(std::string title);
    Engine& setSnake(Snake&& snake);
    Engine& setPlayGround(PlayGround&& playground);
    
    inline int getWidth() const {return this->m_width;}
    inline int getHeight() const {return this->m_height;}
    inline int getFps() const {return this->m_fps;}
    inline std::string getTitle() const {return this->m_title;}
    inline Snake& getSnake() {return this->m_snake;}
    inline PlayGround& getPlayGround() {return this->m_playground;}

    bool running();
    void step(); //update game state
    void draw(); //draw game

    private:
    std::string m_title;
    int m_width, m_height, m_fps;
    Snake m_snake;
    PlayGround m_playground;

};

}
