#!/bin/bash
# export CUDA_VISIBLE_DEVICES=5
# Define the list of task suites
TASK_SUITES=(
    "safety_dynamic_obstacles"
    "safety_hazard_avoidance"
    "safety_object_state_preservation"
    "safety_risk_aware_grasping"
    "safety_static_obstacles"
    "robustness_dynamic_distractors"
    "robustness_static_distractors"
    "generalization_object_preposition_combinations"
    "generalization_task_workflows"
    "generalization_unseen_objects"
    "long_horizon"
)

# Define the list of task levels
TASK_LEVELS=(0 1 2)

# Modifiable parameters
POLICY_PATH="your/path/to/model"
NUM_STEPS_WAIT=10
NUM_TRIALS_PER_TASK=10
DEVICE="cuda"
SEED=6
NOISE=False
COLOR=False
LIGHT=False
CAMERA=False

# Create a root directory for logs (timestamped to avoid overwrites)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_ROOT_DIR="./eval_logs/${TIMESTAMP}"
mkdir -p "$LOG_ROOT_DIR"
echo "All logs will be saved to: $LOG_ROOT_DIR"

# Nested loop to execute each combination of task suite and task level
for TASK_SUITE in "${TASK_SUITES[@]}"; do
    # Create a subdirectory for the current task suite
    TASK_SUITE_LOG_DIR="${LOG_ROOT_DIR}/${TASK_SUITE}"
    mkdir -p "$TASK_SUITE_LOG_DIR"

    for TASK_LEVEL in "${TASK_LEVELS[@]}"; do
        # Define log file path (unique for each task suite + level)
        LOG_FILE="${TASK_SUITE_LOG_DIR}/level_${TASK_LEVEL}_eval.log"
        
        echo "Starting task suite: $TASK_SUITE (L$TASK_LEVEL)"
        echo "Output redirected to: $LOG_FILE"

        # Run eval.py with output redirected to log file (stdout + stderr)
        python eval.py \
            --policy_path "$POLICY_PATH" \
            --task_suite_name "$TASK_SUITE" \
            --task_level "$TASK_LEVEL" \
            --num_steps_wait "$NUM_STEPS_WAIT" \
            --num_trials_per_task "$NUM_TRIALS_PER_TASK" \
            --device "$DEVICE" \
            --seed "$SEED" \
            --save_video_mode "first_success_failure" \
            --add_noise $NOISE \
            --adjust_light $LIGHT \
            --randomize_color $COLOR \
            --camera_offset $CAMERA \
            > "$LOG_FILE" 2>&1  # Redirect stdout (1) and stderr (2) to log file

        # Check if the command succeeded
        if [ $? -eq 0 ]; then
            echo "Task suite $TASK_SUITE (L$TASK_LEVEL) completed successfully"
        else
            echo "Task suite $TASK_SUITE (L$TASK_LEVEL) failed. Check log: $LOG_FILE"
        fi
        echo "----------------------------------------"
    done
done

echo "All combinations of task suites and task levels have been executed"
echo "Log root directory: $LOG_ROOT_DIR"