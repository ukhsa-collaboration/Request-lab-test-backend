import type { RltState } from "../types";

interface RequestProgressProps {
  state: RltState;
  progress: number;
  message: string;
}

const steps: {
  state: RltState;
  label: string;
}[] = [
  {
    state: "SUBMITTED",
    label: "Request submitted",
  },

  {
    state: "TERMINOLOGY_RESOLVED",
    label: "Terminology resolved",
  },

  {
    state: "FHIR_REQUEST_CREATED",
    label: "FHIR request created",
  },

  {
    state: "SENT_TO_MOLIS",
    label: "Sent to MOLIS",
  },

  {
    state: "ORDER_RECEIVED",
    label: "MOLIS order received",
  },

  {
    state: "RESULT_AVAILABLE",
    label: "Result available",
  },

  {
    state: "RESULT_MAPPED",
    label: "Result mapped",
  },

  {
    state: "COMPLETED",
    label: "Completed",
  },
];

export default function RequestProgress({
  state,
  progress,
  message,
}: RequestProgressProps) {
  const currentIndex =
    steps.findIndex(
      (step) =>
        step.state === state
    );

  const isFailed =
    state === "FAILED";

  return (
    <div className="request-progress">

      <div className="progress-heading">

        <div>

          <div className="eyebrow">
            REQUEST PROCESSING
          </div>

          <h2>
            Processing laboratory request
          </h2>

          <p>
            {message}
          </p>

        </div>

        <div className="progress-percentage">
          {progress}%
        </div>

      </div>


      <div className="progress-track">

        <div
          className="progress-fill"
          style={{
            width: `${Math.min(
              100,
              Math.max(0, progress)
            )}%`,
          }}
        />

      </div>


      <div className="progress-steps">

        {steps.map(
          (step, index) => {

            const completed =
              !isFailed &&
              currentIndex >= 0 &&
              index < currentIndex;

            const current =
              !isFailed &&
              index === currentIndex;

            return (
              <div
                key={step.state}
                className={[
                  "progress-step",
                  completed
                    ? "completed"
                    : "",
                  current
                    ? "current"
                    : "",
                ]
                  .filter(Boolean)
                  .join(" ")}
              >

                <div className="step-indicator">

                  {completed ? (
                    <span>
                      ✓
                    </span>
                  ) : current ? (
                    <span className="current-dot">
                      ●
                    </span>
                  ) : (
                    <span>
                      ○
                    </span>
                  )}

                </div>

                <div className="step-label">
                  {step.label}
                </div>

              </div>
            );
          }
        )}

      </div>


      {isFailed && (

        <div className="progress-error">

          <div className="progress-error-icon">
            !
          </div>

          <div>

            <strong>
              Request failed
            </strong>

            <p>
              {message}
            </p>

          </div>

        </div>

      )}

    </div>
  );
}