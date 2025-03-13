package helper_class;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class TrimTask {
    public static final int LEFT = 1;
    public static final int RIGHT = 2;
    public static final int UP = 3;
    public static final int DOWN = 4;
    private int direction;
    private int length;
    private int pos;
    public TrimTask(int direction, int length, int pos) {
        this.direction = direction;
        this.length = length;
        this.pos = pos;
    }
    public static boolean[][] trim(List<TrimTask> taskList, boolean[][] simpleBoard) {
        int width = simpleBoard.length; //Width is for range of i
        int height = simpleBoard[0].length;
        for (TrimTask t: taskList) {
            if (t.direction == LEFT) { //trim from right to left
                for (int i = width - t.length + 1; i < width; i++) {
                    simpleBoard[i][t.pos] = false;
                }
            } else if (t.direction == RIGHT) {
                for (int i = 0; i < t.length - 1; i++) {
                    simpleBoard[i][t.pos] = false;
                }
            } else if (t.direction == UP) {
                for (int j = 0; j < t.length - 1; j++) {
                    simpleBoard[t.pos][j] = false;
                }
            } else if (t.direction == DOWN) { //trim from top to down
                for (int j = height - t.length + 1; j < height; j++) {
                    simpleBoard[t.pos][j] = false;
                }
            }
        }
        return simpleBoard;
    }

    public static List<TrimTask> trimHelper(Set<Hallway> h, boolean[][] simpleBoard) {
        int width = simpleBoard.length;
        int height = simpleBoard[0].length; //correct?
        List<TrimTask> taskList = new ArrayList<>();

        for (Hallway w: h) {
            int pos = w.getPos();
            if (w.getVertical()) {
                for (int j = height - 1; j >= 0; j--) {
                    if (pos - 1 < 0 || simpleBoard[pos - 1][j] || pos + 1 >= width || simpleBoard[pos + 1][j]) {
                        // check both side is true
                        w.changeEnd(j);
                        //length = Height - 1 - j + 1
                        taskList.add(new TrimTask(DOWN, height - j, pos));
                        break;
                    }
                }
                for (int j = 0; j < height; j++) {
                    if (pos - 1 < 0 || simpleBoard[pos - 1][j] || pos + 1 >= width || simpleBoard[pos + 1][j]) {
                        // check both side is true
                        w.changeStart(j);
                        //length = j + 1
                        taskList.add(new TrimTask(UP, j + 1, pos));
                        break;
                    }
                }
            } else {
                for (int i = width - 1; i >= 0; i--) {
                    if (pos - 1 < 0 || simpleBoard[i][pos - 1] || pos + 1 >= height || simpleBoard[i][pos + 1]) {
                        // check both side is true
                        w.changeEnd(i);
                        //length = Width - 1 - i + 1
                        taskList.add(new TrimTask(LEFT, width - i, pos));
                        break;
                    }
                }
                for (int i = 0; i < width; i++) {
                    if (pos - 1 < 0 || simpleBoard[i][pos - 1] || pos + 1 >= height || simpleBoard[i][pos + 1]) {
                        // check both side is true
                        w.changeStart(i);
                        //length = i + 1
                        taskList.add(new TrimTask(RIGHT, i + 1, pos));
                        break;
                    }
                }
            }
        }
        return taskList;
    }
}

