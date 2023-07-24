#!/usr/bin/env python3
import dataclasses
import json
import re
from dataclasses import dataclass
from optparse import OptionParser

# cf. https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_MetricDatum.html
VALID_UNITS = {"Seconds", "Microseconds", "Milliseconds",
               "Bytes", "Kilobytes", "Megabytes", "Gigabytes", "Terabytes",
               "Bits", "Kilobits", "Megabits", "Gigabits", "Terabits",
               "Percent", "Count"}

DEFAULT_UNIT = "Count"

# cf. https://prometheus.io/docs/concepts/data_model/
LINE_PATTERN = re.compile(r'^([^#\s{}]*)({.*})? \d+')
LABEL_PATTERN = re.compile(r'(\w+)=".+?",')


@dataclass
class MetricDeclaration:
    source_labels: list[str]
    label_matcher: str
    dimensions: list[list[str]]
    metric_selectors: list[str]


@dataclass
class EmfProcessor:
    metric_unit: dict[str, str]
    metric_declaration: list[MetricDeclaration]


if __name__ == '__main__':
    """
    Generates CloudWatch Agent configuration (metric_declaration & metric_unit) from Prometheus metrics data.
    """

    parser = OptionParser(usage="%prog INPUT_FILE [options...]")
    parser.add_option('-o', '--output', dest='output_file', help='Output file')
    parser.add_option('-s', '--source-label', dest='source_labels', action="append", help='Source labels (required)')
    parser.add_option('-l', '--label-matcher', dest='label_matchers', action="append", help='Label matchers (required)')
    parser.add_option('-d', '--dimension', dest='dimensions', action="append", help='Dimensions (required)')
    (options, args) = parser.parse_args()

    # Check arguments
    if len(args) < 1:
        parser.error("At least 1 argument is required")

    input_file = args[0]
    with open(input_file) as f:
        lines = f.readlines()

    # Check options
    for o in parser.option_list:
        if '(required)' not in o.help:
            continue
        if not getattr(options, o.dest):
            parser.error(f"Parameter '{str(o)}' is required")

    output_file = options.output_file
    source_labels = options.source_labels
    label_matcher = ";".join(options.label_matchers)
    base_dimensions = options.dimensions

    # Group metrics by labels
    labels_to_metric_decl: dict[str, MetricDeclaration] = {}
    metric_declarations: list[MetricDeclaration] = []
    metric_units: dict[str, str] = {}
    for line in lines:
        matched = LINE_PATTERN.match(line)
        if not matched:
            continue

        metric_name = matched.group(1)
        label_part = matched.group(2)

        # Search labels for the metric
        if label_part:
            labels = LABEL_PATTERN.findall(label_part)
        else:
            labels = []

        # Search valid units in the metric name
        metric_unit = next((u for u in VALID_UNITS if u.lower() in metric_name), DEFAULT_UNIT)
        metric_units[metric_name] = metric_unit

        metric_selector = f"^{metric_name}$"

        # Make list hashable to use as key
        labels_as_key = repr(labels)[1:-1]
        if labels_as_key in labels_to_metric_decl:
            metric_decl = labels_to_metric_decl[labels_as_key]
            if metric_selector not in metric_decl.metric_selectors:
                metric_decl.metric_selectors.append(metric_selector)
        else:
            dimensions = [base_dimensions + labels]
            labels_to_metric_decl[labels_as_key] = MetricDeclaration(
                source_labels=source_labels,
                label_matcher=label_matcher,
                dimensions=dimensions,
                metric_selectors=[metric_selector])

    for k in sorted(labels_to_metric_decl.keys()):
        v = labels_to_metric_decl[k]
        v.metric_selectors.sort()
        metric_declarations.append(v)

    emf_processor = EmfProcessor(
        metric_unit=metric_units,
        metric_declaration=metric_declarations)

    output = json.dumps(dataclasses.asdict(emf_processor), sort_keys=True, indent=2)
    if output_file:
        with open(output_file, 'w') as f:
            f.write(output)
    else:
        print(output)
