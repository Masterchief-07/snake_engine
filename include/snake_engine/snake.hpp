#pragma once
//#include "raylib.h"
#include <array>
#include <vector>
// #include <utility>

namespace se{


class Snake{

    public:
    using Pos = std::pair<int, int> ;
    enum Direction{
        UP = 0,
        DOWN,
        LEFT,
        RIGTH,
    };

    Snake();
    Snake(
        Snake::Direction dir,
        Snake::Pos pos
    );
    ~Snake();

    void move(Direction dir, int speed=1);
    void add_body(size_t count=1);
    void draw();

    inline const std::vector<Pos>& getBody() const { return this->m_body;}
    inline const Pos& getHead() const { return this->m_body.front();}
    inline const Pos& getTail() const { return this->m_body.back();}
    inline const Direction& getDirection() const { return this->m_direction;}

    private:
    Snake::Direction m_direction;
    std::vector<Pos> m_body;

    static constexpr std::array<Pos, 4> DIRECTIONS{{
        {0, -1}, {0, 1}, {0, -1}, {0, 1}
    }};

};

}
