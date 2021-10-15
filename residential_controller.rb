class Column
    attr_accessor :id, :status, :amountOfFloors, :amountOfElevators, :elevatorList, :callButtonList
    def initialize(id, amountOfFloors, amountOfElevators)
        @ID = id
        @status = 'online'
        @amountOfFloors = amountOfFloors
        @amountOfElevators = amountOfElevators
        @elevatorList = []
        @callButtonList = []
        
        createElevators(amountOfFloors, amountOfElevators)
        createCallButtons(amountOfFloors)
    end

    def display
        puts "Created column #{@id}"
        puts "Number of floors: #{@amountOfFloors}"
        puts "Created Number of elevators: #{@amountOfElevators}"
        puts "----------------------------------"
    end

    def createCallButtons(amountOfFloors)
        for x in 1..(@amountOfFloors) do
            if x < amountOfFloors #'//If it's not the last floor
                callButton = CallButton.new(x + 1, x + 1, 'up') #'//id, status, floor, direction
                @callButtonList.append(callButton) 
            end
            if x > 1 #'//If it's not the first floor
                callButton = CallButton.new(x + 1, x + 1, 'down') #'//id, status, floor, direction
                @callButtonList.append(callButton)    
            #puts "call button  #{@callButtonList[x].ID} +  has been created"
            end
        end
    end
    
    def createElevators(amountOfFloors, amountOfElevators) 
        for x in (0..amountOfElevators-1) 
            elevator = Elevator.new(x + 1, amountOfFloors) #'//id, status, amountOfFloors, currentFloor
            elevatorList.push(elevator)
            #puts("elevator " + String(elevatorList[x].ID) + " has been created")
        end
    end


    def requestElevator(requestedFloor, direction) 
        puts("-CLIENT CALLS THE ELEVATOR AT FLOOR " + String(requestedFloor) + " TO GO " + String(direction) + "-")
        elevator = findElevator(requestedFloor, direction)
        elevator.floorRequestList.push(requestedFloor)
        puts()
        puts("ELEVATOR " + String(elevator.ID) + " MOVING FROM FLOOR " + String(elevator.currentFloor) + " TO FLOOR " + String(requestedFloor))
        elevator.move
        elevator.operateDoors
        return elevator
    end

    def findElevator(requestedFloor, requestedDirection)
        bestElevatorInformations = {
            :bestElevator => nil,
            :bestScore => 5,
            :referenceGap => Float::INFINITY
        }
        elevatorList.each do |elevator|
            if requestedFloor == elevator.currentFloor && elevator.status == 'stopped' && requestedDirection == elevator.direction
                bestElevatorInformations = checkIfElevatorIsBetter(1, elevator, bestElevatorInformations, requestedFloor)
            elsif requestedFloor > elevator.currentFloor && elevator.direction == 'up' && requestedDirection == elevator.direction
                bestElevatorInformations = checkIfElevatorIsBetter(2, elevator, bestElevatorInformations, requestedFloor)
            elsif requestedFloor < elevator.currentFloor && elevator.direction == 'down' && requestedDirection == elevator.direction
                bestElevatorInformations = checkIfElevatorIsBetter(2, elevator, bestElevatorInformations, requestedFloor)
            elsif elevator.status == 'idle'
                bestElevatorInformations = checkIfElevatorIsBetter(3, elevator, bestElevatorInformations, requestedFloor)
            else
                bestElevatorInformations = checkIfElevatorIsBetter(4, elevator, bestElevatorInformations, requestedFloor)
            end
        end
        return bestElevatorInformations[:bestElevator]
    end

    def checkIfElevatorIsBetter(scoreToCheck, elevator, bestElevatorInformations, floor)
        if scoreToCheck < bestElevatorInformations[:bestScore]
            bestElevatorInformations[:bestScore] = scoreToCheck
            bestElevatorInformations[:bestElevator] = elevator
            bestElevatorInformations[:referenceGap] = (elevator.currentFloor - floor).abs
        elsif bestElevatorInformations[:bestScore] == scoreToCheck
            if bestElevatorInformations[:referenceGap] > (elevator.currentFloor - floor).abs
            bestElevatorInformations[:bestScore] = scoreToCheck
            bestElevatorInformations[:bestElevator] = elevator
            bestElevatorInformations[:referenceGap] = (elevator.currentFloor - floor).abs
            end
        end
        return bestElevatorInformations
    end
end

class Elevator
    attr_accessor :floorRequestButtonList, :floorRequestList, :direction, :status, :ID, :currentFloor, :overweight, :door, :amountOfFloors, :obstruction
    def initialize(id, amountOfFloors) 
        @ID = id
        @status = 'idle'
        @amountOfFloors = amountOfFloors
        @currentFloor = 1
        @direction = nil
        @overweight = nil
        @obstruction = nil
        @door = Door.new(id)
        @floorRequestButtonList = [] 
        @floorRequestList = []
        
        createFloorRequestButtons(amountOfFloors)
    end

    def createFloorRequestButtons(amountOfFloors) 
        floorRequestButton = 1
        for x in 1..amountOfFloors 
            floorRequestButton = FloorRequestButton.new(x + 1, x + 1) #'//id, status, floor
            floorRequestButtonList.push(floorRequestButton)
        end
    end

    def requestFloor(requestedFloor)
        @floorRequestList.push(requestedFloor)
        move
        operateDoors
    end 
  
    def move()
        while @floorRequestList.length != 0
            destination = @floorRequestList[0]
            @status = 'moving'
            if @currentFloor < destination
                @direction = 'up'
                while @currentFloor < destination
                    @currentFloor += 1
                    @currentFloor
                end
            elsif @currentFloor > destination
                @direction = 'down'
                while @currentFloor > destination
                    @currentFloor -= 1
                    @currentFloor
                end
            end
            @status = 'idle'
            @floorRequestList.shift # Once the floor is reached it will delete the floor from the request List
        end
    end

    def sortFloorList()
        if direction == 'up'
            floorRequestList.sort
        else
            floorRequestList.reverse
        end
    end

    def operateDoors() 
        @doorStatus = 'opened'
        #WAIT 5 SECONDS
        if !overweight 
            door.status = 'closing'
            
            if !door.obstruction 
                door.status = 'closed'
            
            else
                door.obstruction = false
                operateDoors()
            end
        else
            while overweight 
                @overweight = false
                operateDoors()
            end
        end
    end
end

class CallButton
    attr_accessor :floor, :status, :direction, :ID
    def initialize(id, floor, direction) 
        @ID = id
        @status = ButtonStatus::OFF
        @floor = floor
        @direction = direction
    end
end


class FloorRequestButton
    attr_accessor :floor, :status, :ID
    def initialize(id, floor) 
        @ID = id
        @status = ButtonDirection::UP
        @floor = floor
    end
end


class Door
    attr_accessor :obstruction, :status, :ID
    def initialize(id) 
        @ID = id
        @status = DoorStatus::OPENED
        @obstruction = nil
    end
end

# --COLUMN STATUS -- 
module ColumnStatus
    ONLINE = "online"
    OFFLINE = 'offline'
end

# -- ELEVATOR STATUS --
# module ElevatorStatus
#     STOPPED = 'stopped'
#     IDLE = 'idle'
#     UP = 'up'
#     DOWN = 'down'
# end

# -- BUTTON DIRECTION --
module ButtonDirection
    UP = 'up'
    DOWN = 'down'
end

# -- BUTTON STATUS --
module ButtonStatus
    ON = 'on'
    OFF = 'off'
end

# -- SENSOR STATUS --
module SensorStatus
    ON = 'on'
    OFF = 'off'
end

# -- DOORS STATUS --
module DoorStatus
    OPENED = 'opened'
    CLOSED = 'closed'
end

# -- DISPLAY STATUS --
module DisplayStatus
    ON = 'on'
    OFF = 'off'
end

def scenario1()
    puts()
    puts("______________________________________________________________________________________________")
    puts()
    puts("--------------------SCENARIO #1--------------------")
    column = Column.new(1, 10, 2)
    column.display()
    column.elevatorList[0].currentFloor = 2
    column.elevatorList[1].currentFloor = 6
    puts()
    elevator = column.requestElevator(3, 'up')
    elevator.requestFloor(7)
    puts()
    puts("______________________________________________________________________________________________")
    puts()
end
# ----------------------SCENARIO 2---------------------//

# Elevator 1 is Idle at floor 10
# Elevator 2 is idle at floor 3
# Someone is on the 1st floor and requests the 6th floor.
# Elevator 2 should be sent.
# 2 minutes later, someone else is on the 3rd floor and requests the 5th floor. Elevator 2 should be sent.
# Finally, a third person is at floor 9 and wants to go down to the 2nd floor.
# Elevator 1 should be sent.

def scenario2()
    puts()
    puts("______________________________________________________________________________________________")
    puts()
    puts("--------------------SCENARIO #2--------------------")
    column = Column.new(1, 10, 2)
    column.display()
    column.elevatorList[0].currentFloor = 10
    column.elevatorList[1].currentFloor = 3
    puts()
    puts("-----[REQUEST #1]-----")
    puts()
    elevator = column.requestElevator(1, 'up')
    elevator.requestFloor(6)
    puts()
    puts()
    puts("-----[REQUEST #2]-----")
    puts()
    puts()
    column.elevatorList[1].currentFloor = 6
    elevator = column.requestElevator(3, 'up')
    elevator.requestFloor(5)
    puts()
    puts()
    puts("-----[REQUEST #3]-----")
    puts()
    puts()
    elevator = column.requestElevator(9, 'down')
    elevator.requestFloor(2)
    puts()
    puts("______________________________________________________________________________________________")
    puts()
end
# ----------------------SCENARIO 3---------------------//

# Elevator A is Idle at floor 10
# Elevator B is Moving from floor 3 to floor 6
# Someone is on floor 3 and requests the 2nd floor.
# Elevator A should be sent.
# 5 minutes later, someone else is on the 10th floor and wants to go to the 3rd. Elevator B should be sent.

def scenario3()
    puts()
    puts("______________________________________________________________________________________________")
    puts()
    puts("--------------------SCENARIO #3--------------------")
    column = Column.new(1, 10, 2)
    column.display()
    column.elevatorList[0].currentFloor = 10
    column.elevatorList[1].currentFloor = 3
    column.elevatorList[1].status = 'moving'
    puts()
    puts("-----[REQUEST #1]-----")
    puts()
    elevator = column.requestElevator(3, 'down')
    elevator.requestFloor(2)
    puts()
    puts("-----[REQUEST #2]-----")
    puts()
    column.elevatorList[1].currentFloor = 6
    column.elevatorList[1].status = 'idle'
    elevator = column.requestElevator(10, 'down')
    elevator.requestFloor(3)
    puts()
    puts("______________________________________________________________________________________________")
    puts()
end
''' -------- CALL SCENARIOS -------- '''
#scenario1
#scenario2
#scenario3

