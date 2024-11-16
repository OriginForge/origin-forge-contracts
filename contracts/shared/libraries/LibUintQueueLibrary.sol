// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library UintQueueLibrary {
    struct UintQueue {
        uint256[] data;
    }

    // Add an element to the front of the queue
    function addFront(UintQueue storage queue, uint256 element) internal {
        queue.data.push(element); // Add element at the end
        uint256 len = queue.data.length;
        for (uint256 i = len - 1; i > 0; i--) {
            queue.data[i] = queue.data[i - 1];
        }
        queue.data[0] = element; // Move element to the front
    }

    // Add an element to the back of the queue
    function addBack(UintQueue storage queue, uint256 element) internal {
        queue.data.push(element);
    }

    // Add an element to the middle of the queue at the specified index
    function addMiddle(
        UintQueue storage queue,
        uint256 element,
        uint256 index
    ) internal {
        require(index <= queue.data.length, "Index out of bounds");

        queue.data.push(element); // Add element at the end
        for (uint256 i = queue.data.length - 1; i > index; i--) {
            queue.data[i] = queue.data[i - 1];
        }
        queue.data[index] = element; // Move element to the middle
    }

    // Remove an element from the front of the queue
    function removeFront(UintQueue storage queue) internal returns (uint256) {
        require(queue.data.length > 0, "Queue is empty");

        uint256 element = queue.data[0];
        for (uint256 i = 0; i < queue.data.length - 1; i++) {
            queue.data[i] = queue.data[i + 1];
        }
        queue.data.pop();
        return element;
    }

    // Remove an element from the back of the queue
    function removeBack(UintQueue storage queue) internal returns (uint256) {
        require(queue.data.length > 0, "Queue is empty");

        uint256 element = queue.data[queue.data.length - 1];
        queue.data.pop();
        return element;
    }

    // Remove an element from the middle of the queue at the specified index
    function removeMiddle(
        UintQueue storage queue,
        uint256 index
    ) internal returns (uint256) {
        require(index < queue.data.length, "Index out of bounds");

        uint256 element = queue.data[index];
        for (uint256 i = index; i < queue.data.length - 1; i++) {
            queue.data[i] = queue.data[i + 1];
        }
        queue.data.pop();
        return element;
    }

    // Get the element at the front of the queue
    function front(UintQueue storage queue) internal view returns (uint256) {
        require(queue.data.length > 0, "Queue is empty");
        return queue.data[0];
    }

    // Get the element at the back of the queue
    function back(UintQueue storage queue) internal view returns (uint256) {
        require(queue.data.length > 0, "Queue is empty");
        return queue.data[queue.data.length - 1];
    }

    // Check if the queue is empty
    function isEmpty(UintQueue storage queue) internal view returns (bool) {
        return queue.data.length == 0;
    }

    // Get the number of elements in the queue
    function length(UintQueue storage queue) internal view returns (uint256) {
        return queue.data.length;
    }

    // Get the element at a specific index in the queue
    function get(
        UintQueue storage queue,
        uint256 index
    ) internal view returns (uint256) {
        require(index < queue.data.length, "Index out of bounds");
        return queue.data[index];
    }

    // Get the elements from the specified range of indices in the queue
    function getRange(
        UintQueue storage queue,
        uint256 fromIndex,
        uint256 toIndex
    ) internal view returns (uint256[] memory) {
        require(fromIndex <= toIndex, "Invalid index range");
        require(toIndex < queue.data.length, "Index out of bounds");

        uint256 length = toIndex - fromIndex + 1;
        uint256[] memory range = new uint256[](length);
        for (uint256 i = fromIndex; i <= toIndex; i++) {
            range[i - fromIndex] = queue.data[i];
        }
        return range;
    }

    // Get the elements from the specified range of indices in the queue in reverse order
    function getRangeReverse(
        UintQueue storage queue,
        uint256 fromIndex,
        uint256 toIndex
    ) internal view returns (uint256[] memory) {
        require(fromIndex <= toIndex, "Invalid index range");
        require(toIndex < queue.data.length, "Index out of bounds");

        uint256 length = toIndex - fromIndex + 1;
        uint256[] memory range = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            range[i] = queue.data[toIndex - i];
        }
        return range;
    }

    function findIndex(
        UintQueue storage queue,
        uint256 element
    ) internal view returns (int256) {
        for (uint256 i = 0; i < queue.data.length; i++) {
            if (queue.data[i] == element) {
                return int256(i);
            }
        }
        return -1; // Return -1 if the element is not found
    }

    function removeElement(
        UintQueue storage queue,
        uint256 element
    ) internal returns (bool) {
        int256 index = findIndex(queue, element);
        if (index == -1) {
            return false; // Element not found
        }

        for (uint256 i = uint256(index); i < queue.data.length - 1; i++) {
            queue.data[i] = queue.data[i + 1];
        }
        queue.data.pop();
        return true;
    }
}